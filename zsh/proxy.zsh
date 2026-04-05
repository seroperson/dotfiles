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

# Auto-enable proxy in WSL
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
  proxy_on
fi
