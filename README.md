# Setting up a new PC 
When setting up a new computer the first thing that you will need to do is install nix. That can be done with this single shell command: 
```
sh <(curl -L https://nixos.org/nix/install)
```

Once nix is installed we need to create the .config directory `mkdir .config`
You can then clone this repository into that config directory

On the first run you will need to run this command: 
```
nix run home-manager/master -- switch --flake .
```

Going forward you can run this command: 
```
home-manager switch --flake .
```

To perform some actions like git on macos you will need to isntall xcode
```
xcode-select --install
```

# Updates 
Nix flakes lock packages to a specific point in time which is managed in the flake.lock file. This is so that the same flake on multiple machines will results in the exact same packages. You can update the nix flake with this command `nix flake update`

## Home Manager 
Nix takes care of installing your packages for you whereas home-manager let's you configure the installed packages. A good example is with git, nix will install git for you but home-manager let's you configure your git options for instance your userName and userEmail.

To explore all the various options you can look through this page: https://nix-community.github.io/home-manager/options.xhtml

## File Descriptions 
### home.nix 
This defines the baseline dependencies needed to get up and running (nixpkgs and home-manager) along with the specific system configurations. 

### flake.nix 
This defines the configuration we are using nix to apply.
