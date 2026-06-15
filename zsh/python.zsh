#!/bin/zsh

# Home-wide Python virtual environment
# Packages are installed automatically on shell start

_PYTHON_VENV_HOME="$XDG_DATA_HOME/python-venv"
_PYTHON_VENV_PACKAGES=(
  bittensor-cli
)
_PYTHON_VENV_SENTINEL="$_PYTHON_VENV_HOME/.installed"

# Create venv if it doesn't exist
if [[ ! -d "$_PYTHON_VENV_HOME" ]]; then
  python3 -m venv "$_PYTHON_VENV_HOME"
fi

# Activate without setting VIRTUAL_ENV to avoid prompt changes
# (zimfw/minimal theme renders VIRTUAL_ENV basename in PS1)
path=("$_PYTHON_VENV_HOME/bin" $path)

_pyvenv_install() {
  "$_PYTHON_VENV_HOME/bin/pip" install -q "${_PYTHON_VENV_PACKAGES[@]}" >/dev/null 2>&1 \
    && print -r -- "${(F)_PYTHON_VENV_PACKAGES}" > "$_PYTHON_VENV_SENTINEL"
}

# Run pip only when the tracked package list has changed since last install
if [[ ! -f "$_PYTHON_VENV_SENTINEL" ]] || [[ "$(<$_PYTHON_VENV_SENTINEL)" != "${(F)_PYTHON_VENV_PACKAGES}" ]]; then
  zsh-defer -c '_pyvenv_install &!'
fi

# upgrades every tracked package to its latest version
python-venv-update() {
  "$_PYTHON_VENV_HOME/bin/pip" install -U "${_PYTHON_VENV_PACKAGES[@]}" \
    && print -r -- "${(F)_PYTHON_VENV_PACKAGES}" > "$_PYTHON_VENV_SENTINEL"
}
