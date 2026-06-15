#!/bin/zsh

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

# Quick TCP probe with hard timeout so we don't export a dead proxy URL
# Uses timeout(1) + bash /dev/tcp because zsh's ztcp has no native connect timeout
__proxy_reachable() {
  command -v timeout >/dev/null 2>&1 || return 0
  command -v bash >/dev/null 2>&1 || return 0
  timeout 1 bash -c ">/dev/tcp/$1/$2" 2>/dev/null
}

proxy_on() {
  local proxy_host="${1:-$(__detect_wsl_host)}"
  local proxy_port="${2:-10808}"
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

# Auto-enable proxy in WSL only when the proxy port answers
# Uses __wsl_host_fast (cache-only, background refresh) instead of the blocking
# powershell.exe probe - zsh-defer runs tasks synchronously and cannot interrupt
# one mid-flight, so a slow body here freezes ZLE for its full duration
_proxy_auto_enable() {
  [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || return
  local h
  h="$(__wsl_host_fast)"
  [[ -n "$h" ]] && __proxy_reachable "$h" 10808 && proxy_on "$h" 10808
}
