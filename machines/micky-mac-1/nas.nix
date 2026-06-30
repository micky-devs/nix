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
# Implementation notes (verified on macOS 26.5.x):
#   - There is no /etc/auto_master.d directory; the only supported mechanism is
#     a line in /etc/auto_master referencing a map file.
#   - A `/-` *direct* map into /Volumes does NOT work: `/` is a read-only system
#     volume, so autofs cannot claim mountpoints there and reports
#     "mountpoint unavailable" / "no mountpoints". We therefore use an
#     *indirect* map mounted at /Volumes: the auto_master line is
#     `/Volumes auto_nfs`, and each map key is a bare share name. autofs then
#     creates /Volumes/<ShareName> on demand as a trigger and mounts onto it.
#   - nix-darwin has no native autofs module, so we manage the map file and the
#     /etc/auto_master entry idempotently from an activation script rather than
#     clobbering the Apple-managed /etc/auto_master wholesale.
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

  # Indirect map: one line per share. The KEY is the bare share name (autofs
  # prepends the /Volumes mountpoint from auto_master), then options, then the
  # remote. Format:
  #   <key>  -<options>  <server>:<path>
  autoNfsMapText =
    lib.concatMapStringsSep "\n"
      (share:
        "${share}\t-fstype=nfs,${mountOpts}\t${nfsServer}:/${share}/.data")
      shareNames
    + "\n";

  # Marker-tagged indirect-map line for /etc/auto_master: mount the auto_nfs map
  # at /Volumes so its keys become /Volumes/<ShareName>. The marker (kept free of
  # regex/sed-delimiter metacharacters) lets the activation script update the
  # line idempotently.
  autoMasterMarker = "managed-by-nix:unas-nfs";
  autoMasterLine = "/Volumes\t\t/etc/auto_nfs\t# ${autoMasterMarker}";
in
{
  # We manage /etc/auto_nfs and the /etc/auto_master entry together from the
  # activation script (rather than environment.etc) so the map file and its
  # registration always stay in sync, and so automount is reloaded afterwards.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    echo "[unas-nfs] configuring autofs NFS mounts..." >&2

    # 1. Write the autofs indirect map.
    cat > /etc/auto_nfs <<'UNAS_NFS_MAP_EOF'
${autoNfsMapText}UNAS_NFS_MAP_EOF
    chmod 644 /etc/auto_nfs

    # 2. Register the indirect map in /etc/auto_master idempotently: rewrite the
    #    file without any prior nix-managed line (matched by the marker), then
    #    append the current one. Using grep -v (rather than sed) avoids
    #    delimiter/metacharacter pitfalls. This preserves Apple's default
    #    entries and avoids duplicates on re-activation.
    if /usr/bin/grep -qF '${autoMasterMarker}' /etc/auto_master; then
      /usr/bin/grep -vF '${autoMasterMarker}' /etc/auto_master > /etc/auto_master.tmp
      /bin/mv /etc/auto_master.tmp /etc/auto_master
    fi
    printf '%s\n' '${autoMasterLine}' >> /etc/auto_master

    # 3. Reload autofs so the new map takes effect without a reboot. Mounts are
    #    on-demand: accessing /Volumes/Media (etc.) triggers the actual mount.
    /usr/sbin/automount -vc >&2 || true
    echo "[unas-nfs] done — access /Volumes/Media to trigger a mount." >&2
  '';
}
