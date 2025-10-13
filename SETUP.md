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

1. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   Follow the post-installation instructions to add Homebrew to your PATH, then restart your terminal.

2. Install Nix on the new machine:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   **IMPORTANT**: When asked "Install Determinate Nix?", answer **NO** to use the official NixOS Nix instead. Determinate Nix conflicts with nix-darwin installation.

3. Ensure your hostname is correct:
   ```bash
   scutil --get ComputerName
   scutil --get LocalHostName
   ```
   If needed, set it to `micky-mac-air`:
   ```bash
   sudo scutil --set ComputerName "micky-mac-air"
   sudo scutil --set LocalHostName "micky-mac-air"
   ```

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

If you installed Determinate Nix by mistake (answered "yes" to the Determinate Nix question), uninstall it first:

```bash
/nix/nix-installer uninstall
```

Then reinstall with the official version:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Answer **NO** when asked about Determinate Nix.
