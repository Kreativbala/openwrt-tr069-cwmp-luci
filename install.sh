#!/bin/sh
# One-step installer for OpenWrt 25.12+ (aarch64_cortex-a53 / MediaTek Filogic)
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/4] Installing TR-069 (icwmp, stunc, bbfdm) packages..."
apk add --allow-untrusted "$DIR"/packages/aarch64_cortex-a53/*.apk

echo "[2/4] Installing LuCI TR-069 (CWMP) Web UI..."
cp -f "$DIR/luci-app-cwmp/htdocs/luci-static/resources/view/cwmp.js" /www/luci-static/resources/view/cwmp.js
cp -f "$DIR/luci-app-cwmp/root/usr/share/luci/menu.d/luci-app-cwmp.json" /usr/share/luci/menu.d/luci-app-cwmp.json
cp -f "$DIR/luci-app-cwmp/root/usr/share/rpcd/acl.d/luci-app-cwmp.json" /usr/share/rpcd/acl.d/luci-app-cwmp.json

echo "[3/4] Auto-populating factory device info (Serial / MAC / Model) for TR-069..."
mkdir -p /etc/board-db/config
if [ ! -f /etc/board-db/config/device ]; then
	SN=$(strings /dev/mtd2 2>/dev/null | awk -F= '/^SN=/{print $2; exit}')
	[ -z "$SN" ] && SN=$(cat /sys/class/net/br-lan/address 2>/dev/null | tr -d ':' | tr 'a-f' 'A-F')
	MAC=$(cat /sys/class/net/br-lan/address 2>/dev/null)
	OUI=$(echo "$MAC" | cut -d: -f1-3 | tr -d ':' | tr 'a-f' 'A-F')
	MODEL=$(jsonfilter -i /etc/board.json -e '@.model.name' 2>/dev/null || echo "OpenWrt")
	cat << EOF > /etc/board-db/config/device
config device 'deviceinfo'
	option Manufacturer 'OpenWrt'
	option ManufacturerOUI '$OUI'
	option ModelName '$MODEL'
	option ProductClass 'OpenWrt'
	option SerialNumber '$SN'
	option HardwareVersion '1.0'
	option SoftwareVersion '$(awk -F"'" '/DISTRIB_RELEASE/{print $2}' /etc/openwrt_release)'
	option BaseMacAddr '$MAC'
EOF
fi

echo "[4/4] Restarting services..."
rm -rf /tmp/luci-indexcache* /tmp/luci-modulecache*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
/etc/init.d/bbfdmd restart
/etc/init.d/stunc restart || true
/etc/init.d/icwmpd restart

echo "Done! Open LuCI -> Services -> TR-069 (CWMP)"
