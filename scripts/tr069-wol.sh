#!/bin/sh
# Wake-on-LAN trigger via TR-069 (Device.DeviceInfo.ProvisioningCode -> cwmp.cpe.provisioning_code)
VAL=$(uci -q get cwmp.cpe.provisioning_code)
[ -z "$VAL" ] && exit 0
[ "$VAL" = "00:00:00:00:00:00" ] && exit 0

# Match if starts with MAC address (XX:XX:XX:XX:XX:XX or XX-XX-XX-XX-XX-XX)
MAC=$(echo "$VAL" | sed -nE 's/^([0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}).*/\1/p' | tr '-' ':' | tr 'a-f' 'A-F')
if [ -n "$MAC" ] && [ "$MAC" != "00:00:00:00:00:00" ]; then
	logger -t wol "TR-069 Wake-on-LAN triggered for MAC $MAC"
	for i in 1 2 3; do
		/usr/bin/etherwake -D -i br-lan "$MAC" 2>/dev/null || true
		/usr/bin/etherwake -i br-lan "$MAC" 2>/dev/null || true
	done
	uci -q set cwmp.cpe.provisioning_code="WOL_OK:$MAC"
	uci -q commit cwmp
fi
