# Out-of-tree driver for the secondary USB WiFi dongle.
#
# The dongle enumerates as 0bda:1a2b in CD-ROM/DISK mode and, after a
# usb_modeswitch eject, as 3625:010d "802.11ac WLAN Adapter". Despite that
# string the silicon is an RTL8710BU (marketed as "RTL8188GU"): there is no
# mainline or nixpkgs driver for it. The only driver is McMCCRU/rtl8188gu
# (last updated 2021), which does not compile on kernel 6.18 as-is. The
# postPatch below ports it; each substitution maps a 2021-era kernel API to
# its 6.18 equivalent.
#
# This module is intentionally boot-safe: the module is built and installed
# (so depmod registers its modalias) but is NOT force-loaded via
# boot.kernelModules. udev autoloads it on demand only when the dongle is
# present, so boot never depends on it and an absent dongle is a no-op.
{ config, lib, pkgs, ... }:
let
  rtl8188gu = config.boot.kernelPackages.callPackage (
    { stdenv, lib, fetchFromGitHub, kernel, bc }:
    stdenv.mkDerivation {
      pname = "rtl8188gu";
      version = "mcmccru-unstable-2021-09-27-${kernel.version}";
      src = fetchFromGitHub {
        owner = "McMCCRU";
        repo = "rtl8188gu";
        rev = "c2b79fc1c085d9fc4a70ac0f5bc730ec929c562b";
        hash = "sha256-JRIi/UBYSK2AC+hj2jYCrWzNkTIW3DyGOG/p7NJFZNE=";
      };
      # bc is needed by the kernel's own build scripts during the module build.
      nativeBuildInputs = kernel.moduleBuildDependencies ++ [ bc ];
      hardeningDisable = [ "pic" "format" ];
      enableParallelBuilding = true;
      postPatch = ''
        # Kernel 6.x dropped the legacy EXTRA_CFLAGS shim; Kbuild now only reads
        # ccflags-y. Without this rename every -I include path and -D chip-select
        # define in the driver is silently ignored and the build cannot find its
        # own headers. Both the top Makefile and phydm.mk are affected.
        substituteInPlace Makefile hal/phydm/phydm.mk --replace-quiet 'EXTRA_CFLAGS' 'ccflags-y'

        # Advertise monitor mode: gates BIT(NL80211_IFTYPE_MONITOR) in the
        # wiphy's interface_modes (and software_iftypes). Off by default upstream.
        substituteInPlace Makefile --replace-quiet 'CONFIG_WIFI_MONITOR = n' 'CONFIG_WIFI_MONITOR = y'

        # Kernel 6.16 removed the old timer API names.
        for f in $(grep -rl 'del_timer\|from_timer' . --include='*.c' --include='*.h'); do
          substituteInPlace "$f" \
            --replace-quiet 'del_timer_sync' 'timer_delete_sync' \
            --replace-quiet 'del_timer(' 'timer_delete(' \
            --replace-quiet 'from_timer' 'timer_container_of'
        done

        # Kernel 6.15 flattened struct usb_driver: drvwrap.driver -> driver.
        substituteInPlace os_dep/linux/usb_intf.c \
          --replace-quiet '.usbdrv.drvwrap.driver.shutdown' '.usbdrv.driver.shutdown'

        # cfg80211_ops callback signatures that gained parameters / changed types
        # across kernel 6.x (radio_idx/link_id for multi-radio/MLO, the
        # cfg80211_ap_update beacon struct, and the net_device arg on
        # set_monitor_channel). The last two lines are the crucial fix: the driver
        # registered the monitor vif with bare register_netdevice() from inside a
        # cfg80211 callback (wiphy mutex held), which deadlocks rtnl on modern
        # kernels and hard-hangs the box. cfg80211_(un)register_netdevice() is the
        # wrapper the kernel added (~5.12) for exactly this context.
        substituteInPlace os_dep/linux/ioctl_cfg80211.c \
          --replace-quiet 'static int cfg80211_rtw_set_wiphy_params(struct wiphy *wiphy, u32 changed)' 'static int cfg80211_rtw_set_wiphy_params(struct wiphy *wiphy, int radio_idx, u32 changed)' \
          --replace-quiet '	enum nl80211_tx_power_setting type, int mbm)' '	int link_id, enum nl80211_tx_power_setting type, int mbm)' \
          --replace-quiet '	int *dbm)' '	int radio_idx, unsigned int link_id, int *dbm)' \
          --replace-quiet 'struct cfg80211_beacon_data *info)' 'struct cfg80211_ap_update *info)' \
          --replace-quiet 'info->head, info->head_len, info->tail, info->tail_len' 'info->beacon.head, info->beacon.head_len, info->beacon.tail, info->beacon.tail_len' \
          --replace-quiet 'cfg80211_rtw_set_monitor_channel(struct wiphy *wiphy' 'cfg80211_rtw_set_monitor_channel(struct wiphy *wiphy, struct net_device *ndev' \
          --replace-quiet 'register_netdevice(mon_ndev)' 'cfg80211_register_netdevice(mon_ndev)' \
          --replace-quiet 'unregister_netdevice(ndev)' 'cfg80211_unregister_netdevice(ndev)'

        # This specific dongle's post-modeswitch id (3625:010d) is a rebadge not in
        # the upstream table; register it as an RTL8710B so the driver binds.
        substituteInPlace os_dep/linux/usb_intf.c \
          --replace-quiet '{USB_DEVICE_AND_INTERFACE_INFO(USB_VENDER_ID_REALTEK, 0x2005, 0xff, 0xff, 0xff), .driver_info = RTL8710B}, /* TOTOLINK N150UA-B, 8188GU 1*1 */' '{USB_DEVICE_AND_INTERFACE_INFO(USB_VENDER_ID_REALTEK, 0x2005, 0xff, 0xff, 0xff), .driver_info = RTL8710B}, /* TOTOLINK N150UA-B, 8188GU 1*1 */
	{USB_DEVICE_AND_INTERFACE_INFO(0x3625, 0x010D, 0xff, 0xff, 0xff), .driver_info = RTL8710B},'
      '';
      makeFlags = [
        "ARCH=x86_64"
        "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];
      installPhase = ''
        mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless
        cp *.ko $out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/
      '';
      meta.platforms = lib.platforms.linux;
    }
  ) { };
in {
  # Build + install the module (registers its modalias via depmod) but do not
  # force-load it at boot. udev autoloads 8188gu when the dongle appears.
  boot.extraModulePackages = [ rtl8188gu ];

  environment.systemPackages = [ pkgs.usb-modeswitch pkgs.iw ];

  # Flip the dongle out of CD-ROM/DISK mode into WiFi mode on plug-in.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 0bda -p 1a2b -K"
  '';
}
