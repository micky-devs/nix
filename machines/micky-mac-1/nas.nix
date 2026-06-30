{ config, pkgs, lib, ... }:

# NFS mounts for the UNAS Pro, managed via macOS autofs.
#
# The cluster's nfsv4-pseudoroot service (see homelab/unas-nfsv4) exposes the
# shares under an NFSv4 pseudo-root, so paths are root-relative: a share called
# "Media" is mounted from `unas.home:/Media/.data`. All client identities are
# squashed server-side (all_squash), so macOS doesn't need to match UID/GID —
# files simply appear owned by the squash identity, which is fine for browsing
# and reading config files.
#
# autofs mounts on-demand the first time the mount point is accessed and
# survives reboots, which makes it suitable as a boot-time dependency (e.g. the
# Lima worker reads its config from the NAS).
#
# Implementation note: macOS (verified on 26.5.x) does NOT source an
# auto_master.d directory — the only supported mechanism is a line in
# /etc/auto_master referencing a map file. nix-darwin has no native autofs
# module, so we manage both the map file and the /etc/auto_master entry
# idempotently from an activation script rather than clobbering the
# Apple-managed /etc/auto_master wholesale.
#
# NOTE: NFS access is gated by the export's allowed client list (currently
# 192.168.4.0/24 in unas-nfsv4/install.sh). The Mac's IP must fall in that range
# or the mount will be refused regardless of network reachability.

let
  nfsServer = "unas.home";

  # Shares to expose, mapped to their /Volumes mount point. Keep in sync with
  # `shares` in homelab/src/components/unas.ts.
  shares = {
    "Homelab" = "/Volumes/homelab";
    "Media" = "/Volumes/media";
    "Photos" = "/Volumes/photos";
  };

  # macOS NFSv4.1 client options:
  #   vers=4.1   — match the cluster (and the pseudo-root namespace).
  #   resvport   — macOS uses non-reserved source ports by default, which many
  #                NFS servers reject; this forces a reserved (<1024) port.
  #   rw,hard    — read-write, retry indefinitely on server hiccups.
  mountOpts = "rw,vers=4.1,resvport,hard";

  # autofs direct map (/-): one line per share. Format:
  #   <mountpoint>  -<options>  <server>:<path>
  autoNfsMap = pkgs.writeText "auto_nfs" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (share: mountPoint:
          "${mountPoint}\t-fstype=nfs,${mountOpts}\t${nfsServer}:/${share}/.data")
        shares
    ) + "\n"
  );

  # The line we add to /etc/auto_master. A leading `/-` declares a direct map,
  # meaning each entry in the map specifies its own absolute mount point.
  autoMasterLine = "/-\t\t\t/etc/auto_nfs\t-nobrowse";
in
{
  # Install the map file into /etc (nix-darwin manages /etc/auto_nfs).
  environment.etc."auto_nfs".source = autoNfsMap;

  # Idempotently register the direct map in /etc/auto_master and reload autofs.
  # We append our line only if it isn't already present, so we don't disturb
  # Apple's default entries or duplicate on repeated activations.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    echo "Configuring autofs for UNAS NFS mounts..." >&2
    if ! /usr/bin/grep -qF '/etc/auto_nfs' /etc/auto_master; then
      printf '%s\n' '${autoMasterLine}' >> /etc/auto_master
    fi
    /usr/sbin/automount -vc || true
  '';
}
