# Multi-Machine Nix Setup Guide

This configuration supports multiple macOS machines using nix-darwin and home-manager.

## Directory Structure

```
nix/
├── flake.nix                    # Main flake configuration
├── secrets.example.nix          # Template for per-machine secrets (committed)
├── common/
│   ├── darwin.nix              # Shared system packages & settings
│   └── home.nix                # Shared home-manager config
├── machines/
│   ├── machine-name/           # Machine-specific configs (one dir per machine)
│   │   ├── darwin.nix
│   │   ├── home.nix
│   │   └── secrets.nix         # Machine-specific secrets (gitignored)
│   └── ...
└── scripts/                     # Setup scripts
```

> Each directory under `machines/` is named after a machine's hostname. The hostname you set on a machine **must match** its directory name here (and the entry in the `machines` list in `flake.nix`), as the flake selects the config by hostname.
>
> If you can't (or don't want to) change a machine's real hostname — e.g. a work laptop with an auto-generated name like `m73292224` — add it to the `hostAliases` map in `flake.nix` instead: `"m73292224" = "micky-mac-slalom";`. The flake registers the config under both the friendly directory name and the real hostname, so auto-detection and `rebuild` keep working without renaming anything.

## Secrets and Per-Machine Values

Sensitive and machine-specific values (macOS username, git identity, AWS accounts, private hostnames) live in a per-machine `secrets.nix` file. These files are **gitignored** and never committed.

`secrets.example.nix` (committed) documents the expected shape. Each machine's `secrets.nix` returns an attribute set that the flake reads and passes to the config as `secrets`. Files reference specific values, e.g. `secrets.username`, `secrets.gitUser`, `secrets.awsProfiles`.

When building, Nix only evaluates the current machine's configuration, so a machine only needs **its own** `secrets.nix`. Other machines in the `machines` list fall back to `secrets.example.nix` during whole-flake commands (e.g. `nix flake check`), so evaluation never fails.

To set up secrets on a machine:

```bash
cp secrets.example.nix machines/<hostname>/secrets.nix
# then edit machines/<hostname>/secrets.nix with the real values
```

At minimum a machine's `secrets.nix` must define `username` and `gitUser`. Add `awsProfiles` and `mcp` only if that machine's `home.nix` references them.

> The `flake.lock` file **is** committed intentionally. It pins the exact `nixpkgs`/`darwin`/`home-manager` revisions so every machine resolves to identical package versions — this is what keeps environments consistent across devices. Update it deliberately with `nix flake update` and commit the result. Do not gitignore it.

## Setting Up a New Machine

### Prerequisites

1. Ensure your hostname is correct (the flake selects the machine config by hostname, so set this first). It **must match** the machine's directory name under `machines/` and its entry in the `machines` list in `flake.nix`:
   ```bash
   scutil --get ComputerName
   scutil --get LocalHostName
   ```
   If needed, set it (replace `machine-name` with this machine's name):
   ```bash
   sudo scutil --set ComputerName "machine-name"
   sudo scutil --set LocalHostName "machine-name"
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

### Installation Steps

1. Clone this nix configuration to the new machine:
   ```bash
   mkdir -p ~/.config
   cd ~/.config
   git clone <your-repo-url> nix
   ```

2. Create this machine's secrets file (it is gitignored, so it must be created on each machine). At minimum set `username` (must match your macOS username) and `gitUser`:
   ```bash
   cd ~/.config/nix
   cp secrets.example.nix machines/<hostname>/secrets.nix
   # edit machines/<hostname>/secrets.nix with the real values
   ```

3. Back up the default macOS shell configuration files (nix-darwin will replace these; it fails if they already exist):
   ```bash
   sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
   sudo mv /etc/zprofile /etc/zprofile.before-nix-darwin
   sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
   sudo mv /etc/bash_profile /etc/bash_profile.before-nix-darwin
   ```

4. Install nix-darwin (the flake will automatically detect your hostname). This must be run with `sudo`:
   ```bash
   sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix
   ```

   > Note: The `--extra-experimental-features "nix-command flakes"` flag is only needed for this **first** run on a fresh Nix install. The config enables these features permanently (`nix.settings.experimental-features` in `common/darwin.nix`), so subsequent rebuilds don't need the flag.

5. After the initial setup, you can use the rebuild alias:
   ```bash
   rebuild
   ```

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

Edit the machine-specific file, e.g., `machines/machine-name/darwin.nix`:

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
- **Secrets / per-machine values**: `machines/<hostname>/secrets.nix` (gitignored)

## Troubleshooting

### Flake Lock Issues

The `flake.lock` is committed and shared by all machines. Only update it deliberately, then commit the result so other machines pick up the same versions:
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

## Keeping Machines in Sync

To keep machines in sync:

1. Make changes on one machine
2. Commit and push to git
3. On the other machine(s), pull changes and rebuild:
   ```bash
   cd ~/.config/nix
   git pull
   rebuild
   ```

## Adding Another Machine

1. Create a new directory: `machines/machine-name/`
2. Copy the darwin.nix and home.nix from an existing machine (they can be mostly empty)
3. Add the hostname to the `machines` list in `flake.nix`:
   ```nix
   machines = [ "machine-name" "another-machine-name" ];
   ```
4. On the new machine, create its `secrets.nix` (see [Secrets and Per-Machine Values](#secrets-and-per-machine-values)):
   ```bash
   cp secrets.example.nix machines/machine-name/secrets.nix
   # edit with the real values; only include awsProfiles/mcp if that machine's home.nix uses them
   ```
5. Run the same installation command on the new machine - it will automatically detect the hostname and apply the correct configuration

