<p align="center">
  <img src="./Assets/logo.svg" width="30%" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/last-commit/MannuVilasara/shell?style=for-the-badge&color=8ad7eb&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="Last Commit" />
  &nbsp;
  <img src="https://img.shields.io/github/stars/MannuVilasara/shell?style=for-the-badge&logo=andela&color=86dbd7&logoColor=D9E0EE&labelColor=1E202B" alt="Stars" />
  &nbsp;
  <img src="https://img.shields.io/github/repo-size/MannuVilasara/shell?color=86dbce&label=SIZE&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repo Size" />
  &nbsp;
  <br />
</p>

<div align="center">
  <video src="https://github.com/user-attachments/assets/1e8849fb-2d56-490b-a943-14fed7ddbcb0" width="100%" />
</div>

## Requirements

- **QuickShell**: Ideally the latest git version.
- **Fonts**:
  - `Symbols Nerd Font`
  - `JetBrainsMono Nerd Font`
- **Dependencies**:
  - `python` (for some scripts)
  - `imagemagick` (required for generating wallpaper thumbnails)
- **Icons**: An icon theme (e.g., Papirus) is recommended for window icons to appear correctly.

## Installation

### User Install
```bash
git clone https://github.com/MannuVilasara/shell ~/.config/quickshell/mannu
```

### System-wide Install
```bash
sudo git clone https://github.com/MannuVilasara/shell /etc/xdg/quickshell/mannu
```

## IPC Calls

You can interact with the shell using `qs ipc` commands.
Format: `qs -c mannu ipc call <target> <function>`

### Available Commands

```bash
ipc call launcher toggle

ipc call clipboard toggle

ipc call sidePanel open
ipc call sidePanel close
ipc call sidePanel toggle
ipc call sidePanel lock
ipc call sidePanel unlock
ipc call sidePanel toggleLock

ipc call wallpaperpanel toggle

ipc call powermenu toggle

ipc call infopanel toggle

ipc call settings toggle

ipc call wallpaper set <path>

ipc call cliphistService update

ipc call lock lock
```
