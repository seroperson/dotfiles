#!/bin/zsh

# SOCKS/HTTP inbound port of the local proxy (v2ray/xray, etc.)
__PROXY_PORT=10808

# True only under WSL (elsewhere the proxy is on localhost).
__proxy_is_wsl() {
  [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]
}

# Default proxy host: the Windows gateway under WSL, otherwise localhost.
__proxy_default_host() {
  if __proxy_is_wsl; then
    __detect_wsl_host
  else
    echo "127.0.0.1"
  fi
}

__detect_wsl_host() {
  # Newer WSL2 versions set this automatically
  if [[ -n "$WSL_HOST_IP" ]]; then
    echo "$WSL_HOST_IP"
    return
  fi

  local cache="/tmp/.wsl_host_ip"

  # Use cached value if less than 1 hour old
  if [[ -s "$cache" ]] && (( $(command date +%s) - $(command stat -c %Y "$cache") < 3600 )); then
    command cat "$cache"
    return
  fi

  local host

  # PowerShell - reliable but slow, hence the cache
  host=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
    '(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1).IPv4Address.IPAddress' \
    2>/dev/null | command tr -d '\r')

  if [[ -n "$host" ]]; then
    echo "$host" > "$cache"
    echo "$host"
    return
  fi

  # Fallback - resolv.conf nameserver (works in default WSL2 NAT mode)
  command sed -n 's/^nameserver[[:space:]]\+//p' /etc/resolv.conf 2>/dev/null | head -1
}

# Non-blocking host lookup for shell startup. Returns the cached IP immediately
# (regardless of age) or the resolv.conf nameserver, and kicks off a detached
# background refresh when the cache is missing or older than 1h. Never runs the
# ~3s powershell.exe probe synchronously, so it can't freeze ZLE on startup.
# A stale/missing cache costs at most one shell of lag, then self-heals.
__wsl_host_fast() {
  if [[ -n "$WSL_HOST_IP" ]]; then
    echo "$WSL_HOST_IP"
    return
  fi

  local cache="/tmp/.wsl_host_ip"

  if [[ ! -s "$cache" ]] || (( $(command date +%s) - $(command stat -c %Y "$cache") >= 3600 )); then
    # __detect_wsl_host repopulates $cache as a side effect; detach it
    __detect_wsl_host >/dev/null 2>&1 &!
  fi

  if [[ -s "$cache" ]]; then
    command cat "$cache"
  else
    command sed -n 's/^nameserver[[:space:]]\+//p' /etc/resolv.conf 2>/dev/null | head -1
  fi
}

# Quick TCP probe with a hard timeout so we never export a dead proxy URL.
# timeout(1)+bash /dev/tcp on Linux/WSL, else nc (ships with macOS); fails
# closed when neither is available.
__proxy_reachable() {
  local host="$1" port="$2"
  if command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
    timeout 1 bash -c ">/dev/tcp/$host/$port" 2>/dev/null
    return
  fi
  if command -v nc >/dev/null 2>&1; then
    nc -z -w1 "$host" "$port" >/dev/null 2>&1
    return
  fi
  return 1
}

proxy_on() {
  local proxy_host="${1:-$(__proxy_default_host)}"
  local proxy_port="${2:-$__PROXY_PORT}"
  if [[ -z "$proxy_host" ]]; then
    echo "proxy_on: could not detect host IP" >&2
    return 1
  fi
  local proxy_url="http://${proxy_host}:${proxy_port}"
  export http_proxy="$proxy_url"
  export https_proxy="$proxy_url"
  export HTTP_PROXY="$proxy_url"
  export HTTPS_PROXY="$proxy_url"
}

proxy_off() {
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
}

# Auto-enable the proxy when its port answers. Under WSL the host comes from
# __wsl_host_fast (cache-only; the blocking powershell probe would freeze ZLE,
# since zsh-defer can't interrupt a running task); elsewhere it's localhost.
_proxy_auto_enable() {
  local h
  if __proxy_is_wsl; then
    h="$(__wsl_host_fast)"
  else
    h="127.0.0.1"
  fi
  [[ -n "$h" ]] && __proxy_reachable "$h" "$__PROXY_PORT" && proxy_on "$h" "$__PROXY_PORT"
}
