#!/bin/bash
# Enables `claude --chrome` to work from WSL2 with Windows-installed Chrome
# Run this from inside your WSL2 distro
#
# This script was written by Claude, see the following link for more info:
#     https://github.com/anthropics/claude-code/issues/14367#issuecomment-3927349991
#
# The script will:
#  - Auto-detect Windows username, WSL distro, Chrome profile, and claude binary
#  - Create the real directory + Extensions symlink for detection
#  - Patch the .bat file (with backup) to bridge to WSL
#  - Create the native host script and manifest if missing
#  - Check the Windows registry
# Idempotent — safe to re-run (skips steps already done)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; exit 1; }

# Check we're in WSL
grep -qi microsoft /proc/version 2>/dev/null || error "This script must be run inside WSL"

# Ensure Windows system32 is on PATH (not always inherited in WSL)
WINSYS="/mnt/c/Windows/System32"
[[ ":$PATH:" == *":$WINSYS:"* ]] || export PATH="$PATH:$WINSYS"

# Detect Windows username
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') || error "Could not detect Windows username"
WIN_HOME="/mnt/c/Users/$WIN_USER"
[ -d "$WIN_HOME" ] || error "Windows home not found at $WIN_HOME"
info "Windows user: $WIN_USER"

# Detect WSL distro name
WSL_DISTRO="${WSL_DISTRO_NAME:-}"
if [ -z "$WSL_DISTRO" ]; then
    # Fallback: parse from wsl.exe
    WSL_DISTRO=$(wsl.exe -l -q 2>/dev/null | tr -d '\0\r' | head -1) || true
fi
[ -n "$WSL_DISTRO" ] || error "Could not detect WSL distro name. Set WSL_DISTRO_NAME env var."
info "WSL distro: $WSL_DISTRO"

# Find claude binary in WSL
CLAUDE_BIN=$(which claude 2>/dev/null) || error "claude not found in PATH. Install Claude Code in WSL first."
# Don't resolve symlinks — keep the stable path so it survives version updates
info "Claude binary: $CLAUDE_BIN"

# Find Chromium-based browser user data
BROWSER_CANDIDATES=(
    "Google/Chrome/User Data"
    "Vivaldi/User Data"
    "BraveSoftware/Brave-Browser/User Data"
    "Microsoft/Edge/User Data"
    "Chromium/User Data"
)
CHROME_DATA=""
BROWSER_NAME=""
for candidate in "${BROWSER_CANDIDATES[@]}"; do
    if [ -d "$WIN_HOME/AppData/Local/$candidate" ]; then
        CHROME_DATA="$WIN_HOME/AppData/Local/$candidate"
        BROWSER_NAME="${candidate%%/*}"
        break
    fi
done
[ -n "$CHROME_DATA" ] || error "No Chromium-based browser found in AppData/Local"
info "Browser data ($BROWSER_NAME): $CHROME_DATA"

# Check extension is installed
EXT_ID="fcoeoabgfenejglbffodgkkbkcdhcgfn"
EXT_FOUND=false
for profile_dir in "$CHROME_DATA"/Default "$CHROME_DATA"/Profile\ *; do
    [ -d "$profile_dir" ] || continue
    if [ -d "$profile_dir/Extensions/$EXT_ID" ]; then
        PROFILE_NAME=$(basename "$profile_dir")
        info "Claude extension found in profile: $PROFILE_NAME"
        EXT_FOUND=true
        break
    fi
done
$EXT_FOUND || error "Claude extension not found in any $BROWSER_NAME profile. Install it from https://claude.ai/chrome"

# --- Step 1: Fix extension detection ---
info "Setting up extension detection..."

# Map browser name to Linux config directory
case "$BROWSER_NAME" in
    Google)    LINUX_CHROME_DIR="$HOME/.config/google-chrome" ;;
    Vivaldi)   LINUX_CHROME_DIR="$HOME/.config/vivaldi" ;;
    BraveSoftware) LINUX_CHROME_DIR="$HOME/.config/BraveSoftware/Brave-Browser" ;;
    Microsoft) LINUX_CHROME_DIR="$HOME/.config/microsoft-edge" ;;
    Chromium)  LINUX_CHROME_DIR="$HOME/.config/chromium" ;;
    *)         LINUX_CHROME_DIR="$HOME/.config/google-chrome" ;;
esac
LINUX_PROFILE_DIR="$LINUX_CHROME_DIR/$PROFILE_NAME"
LINUX_EXT_LINK="$LINUX_PROFILE_DIR/Extensions"
WIN_EXT_DIR="$profile_dir/Extensions"

# Create real directory (not symlink) so Node's isDirectory() works
if [ -L "$LINUX_PROFILE_DIR" ]; then
    info "Removing existing symlink at $LINUX_PROFILE_DIR (won't work with Node's readdir)"
    rm "$LINUX_PROFILE_DIR"
fi

mkdir -p "$LINUX_PROFILE_DIR"

# Symlink Extensions inside the real directory
if [ -L "$LINUX_EXT_LINK" ]; then
    CURRENT_TARGET=$(readlink "$LINUX_EXT_LINK")
    if [ "$CURRENT_TARGET" = "$WIN_EXT_DIR" ]; then
        info "Extensions symlink already correct"
    else
        warn "Updating Extensions symlink (was: $CURRENT_TARGET)"
        rm "$LINUX_EXT_LINK"
        ln -s "$WIN_EXT_DIR" "$LINUX_EXT_LINK"
    fi
elif [ -d "$LINUX_EXT_LINK" ]; then
    warn "Extensions is a real directory, replacing with symlink"
    rmdir "$LINUX_EXT_LINK" 2>/dev/null || error "Cannot replace $LINUX_EXT_LINK - it's not empty"
    ln -s "$WIN_EXT_DIR" "$LINUX_EXT_LINK"
else
    ln -s "$WIN_EXT_DIR" "$LINUX_EXT_LINK"
fi
info "Extension detection: $LINUX_PROFILE_DIR/Extensions -> $WIN_EXT_DIR"

# --- Step 2: Bridge native host to WSL ---
info "Setting up native host bridge..."

BAT_FILE="$WIN_HOME/.claude/chrome/chrome-native-host.bat"
if [ ! -f "$BAT_FILE" ]; then
    warn "Native host .bat not found at $BAT_FILE"
    warn "Run 'claude --chrome' once on Windows to create it, then re-run this script"
    warn "Or, run 'claude --chrome' from WSL first (it will fail but creates the Linux-side files)"
    # Create the directory and bat file ourselves
    mkdir -p "$(dirname "$BAT_FILE")"
    cat > "$BAT_FILE" << BATEOF
@echo off
REM Chrome native host wrapper script - bridges to WSL
REM Generated by setup-claude-chrome-wsl.sh
wsl.exe -d ${WSL_DISTRO} -- ${CLAUDE_BIN} --chrome-native-host
BATEOF
    info "Created $BAT_FILE"
else
    # Check if already patched
    if grep -q "wsl.exe" "$BAT_FILE" 2>/dev/null; then
        info "Native host .bat already bridges to WSL"
    else
        # Back up and patch
        cp "$BAT_FILE" "${BAT_FILE}.bak"
        info "Backed up original to ${BAT_FILE}.bak"
        cat > "$BAT_FILE" << BATEOF
@echo off
REM Chrome native host wrapper script - bridges to WSL
REM Modified by setup-claude-chrome-wsl.sh
wsl.exe -d ${WSL_DISTRO} -- ${CLAUDE_BIN} --chrome-native-host

$(sed 's/^/REM [original] /' "${BAT_FILE}.bak")
BATEOF
        info "Patched $BAT_FILE to bridge to WSL"
    fi
fi

# --- Step 3: Ensure native messaging host manifest exists ---
info "Checking native messaging host manifest..."

NMH_DIR="$LINUX_CHROME_DIR/NativeMessagingHosts"
NMH_FILE="$NMH_DIR/com.anthropic.claude_code_browser_extension.json"
NATIVE_HOST="$HOME/.claude/chrome/chrome-native-host"

mkdir -p "$NMH_DIR"

# Also ensure the Linux-side native host script exists
if [ ! -f "$NATIVE_HOST" ]; then
    mkdir -p "$(dirname "$NATIVE_HOST")"
    cat > "$NATIVE_HOST" << SHEOF
#!/bin/sh
# Chrome native host wrapper script
# Generated by setup-claude-chrome-wsl.sh
exec "$CLAUDE_BIN" --chrome-native-host
SHEOF
    chmod +x "$NATIVE_HOST"
    info "Created $NATIVE_HOST"
fi

# Write the manifest
cat > "$NMH_FILE" << JSONEOF
{
  "name": "com.anthropic.claude_code_browser_extension",
  "description": "Claude Code Browser Extension Native Host",
  "path": "$NATIVE_HOST",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXT_ID/"
  ]
}
JSONEOF
info "Native messaging manifest: $NMH_FILE"

# --- Step 4: Check Windows registry ---
REG_KEY="HKCU\\Software\\Google\\Chrome\\NativeMessagingHosts\\com.anthropic.claude_code_browser_extension"
REG_VALUE=$(reg.exe query "$REG_KEY" /ve 2>/dev/null | tr -d '\r' | grep REG_SZ | awk '{print $NF}') || true

if [ -z "$REG_VALUE" ]; then
    warn "Windows registry key not found for native messaging host"
    warn "The Claude in Chrome extension should create this automatically."
    warn "If it doesn't work, you may need to run 'claude --chrome' on Windows once first."
else
    info "Windows registry: $REG_KEY -> $REG_VALUE"
fi

echo ""
info "Setup complete! Run 'claude --chrome' in WSL to connect to Windows Chrome."
warn "Note: If you update Claude Code on Windows, it may overwrite chrome-native-host.bat — re-run this script if that happens."
