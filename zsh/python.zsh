#!/bin/zsh

# Home-wide Python virtual environment
# Packages are installed automatically on shell start

_PYTHON_VENV_HOME="$XDG_DATA_HOME/python-venv"
_PYTHON_VENV_PACKAGES=(
  bittensor-cli
  graphifyy
  'graphifyy[kimi]'
)

# Create venv if it doesn't exist
if [[ ! -d "$_PYTHON_VENV_HOME" ]]; then
  python3 -m venv "$_PYTHON_VENV_HOME"
fi

# Activate without setting VIRTUAL_ENV to avoid prompt changes
# (zimfw/minimal theme renders VIRTUAL_ENV basename in PS1)
path=("$_PYTHON_VENV_HOME/bin" $path)

# Install missing packages in background (deferred to avoid blocking shell startup)
zsh-defer -c '
  _pv="'"$_PYTHON_VENV_HOME"'"
  _pp=('"${(j: :)${(qq)_PYTHON_VENV_PACKAGES[@]}}"')
  installed="$("$_pv/bin/pip" freeze 2>/dev/null)"
  missing=()
  for pkg in "${_pp[@]}"; do
    if ! echo "$installed" | grep -qi "^${pkg}=="; then
      missing+=("$pkg")
    fi
  done
  if (( ${#missing} )); then
    "$_pv/bin/pip" install -q "${missing[@]}" &>/dev/null &!
  fi
  unset _pv _pp installed missing pkg
'

# upgrades every tracked package to its latest version
python-venv-update() {
  "$_PYTHON_VENV_HOME/bin/pip" install -U "${_PYTHON_VENV_PACKAGES[@]}"
}
