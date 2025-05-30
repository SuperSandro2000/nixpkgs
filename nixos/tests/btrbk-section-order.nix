# This tests validates the order of generated sections that may contain
# other sections.
# When a `volume` section has both `subvolume` and `target` children,
# `target` must go before `subvolume`. Otherwise, `target` will become
# a child of the last `subvolume` instead of `volume`, due to the
# order-sensitive config format.
#
# Issue: https://github.com/NixOS/nixpkgs/issues/195660
{ lib, pkgs, ... }:
{
  name = "btrbk-section-order";
  meta.maintainers = with lib.maintainers; [ oxalica ];

  nodes.machine =
    { ... }:
    {
      services.btrbk.instances.local = {
        onCalendar = null;
        settings = {
          timestamp_format = "long";
          target."ssh://global-target/".ssh_user = "root";
          volume."/btrfs" = {
            snapshot_dir = "/volume-snapshots";
            target."ssh://volume-target/".ssh_user = "root";
            subvolume."@subvolume" = {
              snapshot_dir = "/subvolume-snapshots";
              target."ssh://subvolume-target/".ssh_user = "root";
            };
          };
        };
      };
    };

  testScript = ''
    import difflib
    machine.wait_for_unit("basic.target")
    got = machine.succeed("cat /etc/btrbk/local.conf").strip()
    expect = """
    backend btrfs-progs-sudo
    stream_compress no
    timestamp_format long
    target ssh://global-target/
     ssh_user root
    volume /btrfs
     snapshot_dir /volume-snapshots
     target ssh://volume-target/
      ssh_user root
     subvolume @subvolume
      snapshot_dir /subvolume-snapshots
      target ssh://subvolume-target/
       ssh_user root
    """.strip()
    print(got)
    if got != expect:
      diff = difflib.unified_diff(expect.splitlines(keepends=True), got.splitlines(keepends=True), fromfile="expected", tofile="got")
      print("".join(diff))
    assert got == expect
  '';
}
