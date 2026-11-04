#!/bin/sh
# One-step installer for OpenWrt 25.12+ (aarch64_cortex-a53 / MediaTek Filogic)
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/5] Installing TR-069 (icwmp, stunc, bbfdm) packages..."
apk add --allow-untrusted "$DIR"/packages/aarch64_cortex-a53/*.apk

echo "[2/5] Installing LuCI TR-069 (CWMP) Web UI..."
cp -f "$DIR/luci-app-cwmp/htdocs/luci-static/resources/view/cwmp.js" /www/luci-static/resources/view/cwmp.js
cp -f "$DIR/luci-app-cwmp/root/usr/share/luci/menu.d/luci-app-cwmp.json" /usr/share/luci/menu.d/luci-app-cwmp.json
cp -f "$DIR/luci-app-cwmp/root/usr/share/rpcd/acl.d/luci-app-cwmp.json" /usr/share/rpcd/acl.d/luci-app-cwmp.json

# Register cwmp and stunc in ucitrack so LuCI Save & Apply restarts icwmpd and stunc
if ! uci -q show ucitrack | grep -q "ucitrack.@cwmp"; then
	uci add ucitrack cwmp >/dev/null
	uci set ucitrack.@cwmp[-1].init='icwmpd'
fi
if ! uci -q show ucitrack | grep -q "ucitrack.@stunc"; then
	uci add ucitrack stunc >/dev/null
	uci set ucitrack.@stunc[-1].init='stunc'
fi
uci commit ucitrack

echo "[3/5] Preventing legacy iptables warning on fw4/nftables systems..."
uci -q delete firewall.hosts || true
uci commit firewall
if [ -f /usr/share/hostmngr/hosts_acl.sh ]; then
	printf '#!/bin/sh\nexit 0\n' > /usr/share/hostmngr/hosts_acl.sh
	chmod +x /usr/share/hostmngr/hosts_acl.sh
fi
iptables -F 2>/dev/null || true
iptables -X 2>/dev/null || true
nft delete table ip filter 2>/dev/null || true

echo "[4/5] Auto-populating factory device info (Serial / MAC / Model) for TR-069..."
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

echo "[5/5] Restarting services..."
rm -rf /tmp/luci-indexcache* /tmp/luci-modulecache*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
/etc/init.d/bbfdmd restart
/etc/init.d/stunc restart || true
/etc/init.d/icwmpd restart

echo "Done! Log out and log back into LuCI -> Services -> TR-069 (CWMP)"
