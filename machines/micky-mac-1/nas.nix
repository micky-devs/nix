{ config, pkgs, lib, ... }:

let
  nfsServer = "unas.home";

  # Keep in sync with `shares` in homelab/src/components/unas.ts.
  shareNames = [ "Homelab" "Media" "Photos" ];

  # soft+intr+timeo/retrans so a stalled op fails instead of wedging the whole
  # NFS connection (a `hard` mount hangs indefinitely under write stalls).
  # rsize/wsize=1MiB to use the full 2.5GbE link (macOS defaults are too small).
  mountOpts = "rw,vers=4.1,resvport,soft,intr,timeo=30,retrans=3,rsize=1048576,wsize=1048576";

  # The `..` indirection resolves to /Volumes/<Share> but isn't literally
  # "/Volumes/...", which is what lets macOS autofs claim the mountpoint.
  mountPointFor = share: "/System/Volumes/Data/../Data/Volumes/${share}";

  autoNfsMapText =
    lib.concatMapStringsSep "\n"
      (share:
        "${mountPointFor share}\t-fstype=nfs,${mountOpts}\t${nfsServer}:/${share}/.data")
      shareNames
    + "\n";

  autoMasterMarker = "managed-by-nix:unas-nfs";
  autoMasterLine = "/-\t\t\t/etc/auto_nfs\t# ${autoMasterMarker}";
in
{
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    cat > /etc/auto_nfs <<'UNAS_NFS_MAP_EOF'
${autoNfsMapText}UNAS_NFS_MAP_EOF
    chmod 644 /etc/auto_nfs

    if /usr/bin/grep -qF '${autoMasterMarker}' /etc/auto_master; then
      /usr/bin/grep -vF '${autoMasterMarker}' /etc/auto_master > /etc/auto_master.tmp
      /bin/mv /etc/auto_master.tmp /etc/auto_master
    fi
    printf '%s\n' '${autoMasterLine}' >> /etc/auto_master

    /usr/sbin/automount -vc >&2 || true
  '';
}
