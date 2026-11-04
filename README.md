# OpenWrt 25.12 TR-069 (CWMP) + STUN + BBFDM (TR-181) + LuCI Web UI

Готовый стек **TR-069 (CWMP) + STUN + TR-181 (`bbfdmd` микросервисы)** и графический веб-интерфейс **`luci-app-cwmp`** для **OpenWrt 25.12+** (архитектура `aarch64_cortex-a53` / MediaTek Filogic: Xiaomi AX3000T, Redmi AX6000, Cudy WR3000, GL.iNet MT6000 и др.).

---

## Что входит в проект

1. **`luci-app-cwmp`** — современный веб-интерфейс для LuCI (**Услуги → TR-069 (CWMP)**):
   - Настройка **ACS сервера** (URL, логин/пароль, периодический Inform, интерфейс WAN).
   - Настройка **CPE клиента** (Connection Request порт, логин/пароль, уровень логов).
   - Настройка **STUN-клиента (`stunc`)** для работы и приёма команд от ACS за NAT / «серым» IP провайдера (CGNAT).
2. **Собранные пакеты `.apk` для OpenWrt 25.12 (`aarch64_cortex-a53`)** с важными патчами для провайдеров (GenieACS и др.):
   - `icwmp`, `stunc`, `bbfdmd`, `dm-service`, `libbbfdm-api1.0`, `libbbfdm-ubus`, `bbf_configmngr`, `sysmngr`, `netmngr`, `dhcpmngr`, `ethmngr`, `hostmngr`, `wifimngr`, `libwifi`, `libwifiutils`, `libethernet`, `libeasy`, `mxml`.
   - **Патч `libbbfdm-api1.0` + `wifimngr`**: позволяет ACS-серверу читать и изменять пароли Wi-Fi (`KeyPassphrase`), каналы (`Channel`), ширину и диапазон (`OperatingFrequencyBand`, `Standard`) напрямую через `Device.WiFi.SSID.{i}`.
3. **Wake-on-LAN через TR-069 за любым NAT**:
   - Возможность разбудить компьютер в локальной сети роутера прямо из панели GenieACS через параметр `Device.DeviceInfo.ProvisioningCode` даже за CGNAT провайдера.

---

## Быстрая установка на роутер

Скопируйте репозиторий на роутер в `/tmp` и запустите `sh install.sh`:

```sh
git clone https://github.com/YOUR_USERNAME/openwrt-tr069-cwmp-luci.git /tmp/tr069
sh /tmp/tr069/install.sh
```

После установки откройте веб-интерфейс роутера **LuCI → Услуги (Services) → TR-069 (CWMP)**.

---

## Лицензия

Проект распространяется под лицензией **GPL-2.0** (совместима с пакетами OpenWrt, LuCI и IOPSYS BBFDM/icwmp).
