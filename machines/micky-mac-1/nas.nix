{ config, pkgs, lib, ... }:

# NFS mounts for the UNAS Pro, managed via macOS autofs.
#
# The cluster's nfsv4-pseudoroot service (see homelab/unas-nfsv4) exposes the
# shares under an NFSv4 pseudo-root, so paths are root-relative: a share called
# "Media" is mounted from `unas.home:/Media/.data` to `/Volumes/Media`. All
# client identities are squashed server-side (all_squash), so macOS doesn't need
# to match UID/GID — files appear owned by the squash identity, which is fine
# for browsing and reading config files.
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

  # Share names exactly as exported by the UNAS (capitalised). Each is mounted at
  # /Volumes/<ShareName>. Keep in sync with `shares` in
  # homelab/src/components/unas.ts.
  shareNames = [ "Homelab" "Media" "Photos" ];

  # macOS NFSv4.1 client options (verified working via a manual mount):
  #   vers=4.1   — match the cluster (and the pseudo-root namespace).
  #   resvport   — macOS uses non-reserved source ports by default, which the
  #                UNAS rejects; this forces a reserved (<1024) port.
  #   rw,hard    — read-write, retry indefinitely on server hiccups.
  mountOpts = "rw,vers=4.1,resvport,hard";

  mountPointFor = share: "/Volumes/${share}";

  # autofs direct map (/-): one line per share. Format:
  #   <mountpoint>  -<options>  <server>:<path>
  autoNfsMapText =
    lib.concatMapStringsSep "\n"
      (share:
        "${mountPointFor share}\t-fstype=nfs,${mountOpts}\t${nfsServer}:/${share}/.data")
      shareNames
    + "\n";

  # Marker-tagged line for /etc/auto_master. A leading `/-` declares a direct
  # map, meaning each entry in the map specifies its own absolute mount point.
  # The marker lets the activation script update the line idempotently.
  autoMasterMarker = "# managed-by-nix:unas-nfs";
  autoMasterLine = "/-\t\t\t/etc/auto_nfs\t${autoMasterMarker}";
in
{
  # We manage /etc/auto_nfs and the /etc/auto_master entry together from the
  # activation script (rather than environment.etc) so the map file and its
  # registration always stay in sync, and so automount is reloaded afterwards.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    echo "[unas-nfs] configuring autofs NFS mounts..." >&2

    # 1. Write the autofs direct map.
    cat > /etc/auto_nfs <<'UNAS_NFS_MAP_EOF'
${autoNfsMapText}UNAS_NFS_MAP_EOF
    chmod 644 /etc/auto_nfs

    # 2. Register the direct map in /etc/auto_master idempotently: strip any
    #    prior nix-managed line (matched by the marker), then append the current
    #    one. This preserves Apple's default entries and avoids duplicates.
    if /usr/bin/grep -q '${autoMasterMarker}' /etc/auto_master; then
      /usr/bin/sed -i "" '\#${autoMasterMarker}#d' /etc/auto_master
    fi
    printf '%s\n' '${autoMasterLine}' >> /etc/auto_master

    # 3. Reload autofs so the new map takes effect without a reboot. Mounts are
    #    on-demand: accessing /Volumes/Media (etc.) triggers the actual mount.
    /usr/sbin/automount -vc >&2 || true
    echo "[unas-nfs] done — access /Volumes/Media to trigger a mount." >&2
  '';
}
