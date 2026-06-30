# Multi-Machine Nix Setup Guide

This configuration supports multiple macOS machines using nix-darwin and home-manager.

## Directory Structure

```
nix/
├── flake.nix                    # Main flake configuration
├── common/
│   ├── darwin.nix              # Shared system packages & settings
│   └── home.nix                # Shared home-manager config
├── machines/
│   ├── micky-mac-1/            # Machine-specific configs
│   │   ├── darwin.nix
│   │   └── home.nix
│   └── micky-mac-air/          # Machine-specific configs
│       ├── darwin.nix
│       └── home.nix
├── scripts/                     # Setup scripts
└── configs/                     # Additional config files
```

## Setting Up a New Machine (micky-mac-air)

### Prerequisites

1. Ensure your hostname is correct (the flake selects the machine config by hostname, so set this first):
   ```bash
   scutil --get ComputerName
   scutil --get LocalHostName
   ```
   If needed, set it to `micky-mac-air`:
   ```bash
   sudo scutil --set ComputerName "micky-mac-air"
   sudo scutil --set LocalHostName "micky-mac-air"
   ```

2. Grant your terminal app Full Disk Access. The Nix installer (and nix-darwin activation) will fail without it.
   - Go to **System Settings → Privacy & Security → Full Disk Access**.
   - Enable it for your terminal app (e.g. **Terminal**).
   - Quit and reopen the terminal so the change takes effect.

   > Note: This can be disabled again once setup is complete and you are running Ghostty.

3. Install the Xcode Command Line Tools (provides `git`, required by Homebrew and for cloning this repo):
   ```bash
   xcode-select --install
   ```

   A dialog will appear; follow the prompts to complete the installation. You can verify it succeeded with `xcode-select -p`.

4. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   Follow the post-installation instructions to add Homebrew to your PATH, then restart your terminal.

5. Install Nix on the new machine using the **official NixOS installer**:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

   **IMPORTANT**: Do **not** use the Determinate Systems installer (`install.determinate.systems`). It now installs Determinate Nix outright (the single `y/n` prompt installs Determinate Nix; answering `n` aborts), and Determinate Nix conflicts with nix-darwin. Use the official NixOS installer above instead.

### Installation Steps

1. Clone/copy this nix configuration to the new machine:
   ```bash
   mkdir -p ~/.config
   # Option 1: Clone from git (if you have it in a repo)
   cd ~/.config
   git clone <your-repo-url> nix

   # Option 2: Copy via rsync/scp from your other machine
   # On micky-mac-1:
   rsync -av ~/.config/nix/ micky-mac-air:~/.config/nix/
   ```

2. Back up the default macOS shell configuration files:
   ```bash
   sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
   sudo mv /etc/zprofile /etc/zprofile.before-nix-darwin
   ```

3. Install nix-darwin (the flake will automatically detect your hostname):
   ```bash
   nix run nix-darwin -- switch --flake ~/.config/nix
   ```

4. After the initial setup, you can use the rebuild alias:
   ```bash
   rebuild
   ```

### First Machine Setup (Already Done)

For reference, here's how micky-mac-1 was set up:

```bash
nix run nix-darwin -- switch --flake ~/.config/nix
```

The flake automatically detects the hostname and applies the correct configuration. Then use the `rebuild` alias for future updates.

## Making Changes

### Adding a Package to All Machines

Edit `common/darwin.nix` or `common/home.nix`:

```nix
# In common/darwin.nix
environment.systemPackages = with pkgs; [
  git
  zoxide
  your-new-package  # Add here
];
```

Then rebuild:
```bash
rebuild
```

### Adding a Package to a Specific Machine

Edit the machine-specific file, e.g., `machines/micky-mac-air/darwin.nix`:

```nix
{ pkgs, ... }: {
  imports = [
    ../../common/darwin.nix
  ];

  # Machine-specific packages
  environment.systemPackages = with pkgs; [
    machine-specific-package
  ];
}
```

### Common Configuration Locations

- **System packages & Homebrew**: `common/darwin.nix`
- **User packages & programs**: `common/home.nix`
- **Machine-specific overrides**: `machines/<hostname>/darwin.nix` or `machines/<hostname>/home.nix`

## Troubleshooting

### Flake Lock Issues

If you get flake lock errors:
```bash
cd ~/.config/nix
nix flake update
```

### Homebrew Issues

If Homebrew packages aren't installing:
```bash
brew update
rebuild
```

### SSH Keys

The configuration automatically runs `generateSSHKey.sh` on activation. Ensure this script exists in `scripts/` directory.

## Updating Both Machines

To keep both machines in sync:

1. Make changes on one machine
2. Commit and push to git (or rsync to the other machine)
3. On the other machine, pull changes and rebuild:
   ```bash
   cd ~/.config/nix
   git pull
   rebuild
   ```

## Adding a Third Machine

1. Create a new directory: `machines/new-hostname/`
2. Copy the darwin.nix and home.nix from an existing machine (they can be mostly empty)
3. Add the hostname to the `machines` list in `flake.nix`:
   ```nix
   machines = [ "micky-mac-1" "micky-mac-air" "new-hostname" ];
   ```
4. Run the same installation command on the new machine - it will automatically detect the hostname and apply the correct configuration

## Troubleshooting Installation Issues

### If You Accidentally Installed Determinate Nix

The Determinate Systems installer (`install.determinate.systems`) now installs Determinate Nix from a single `y/n` prompt - there is no longer an option to select official NixOS Nix. Determinate Nix conflicts with nix-darwin, so if you installed it, uninstall it first:

```bash
/nix/nix-installer uninstall
```

Then reinstall with the official NixOS installer:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Verify you are on official Nix with `nix --version` (it should not mention "Determinate") and confirm `/nix/nix-installer` no longer exists.

