# OpenWrt 25.12+ TR-069 (CWMP) + STUN + TR-181 (BBFDM) + LuCI Web UI

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-25.12%2B-00B5E2.svg)](https://openwrt.org/)
[![Architecture](https://img.shields.io/badge/Arch-aarch64__cortex--a53%20(Filogic)-success.svg)](#supported-devices)

🇬🇧 **[English Documentation](#english-documentation)** | 🇷🇺 **[Документация на русском языке](#документация-на-русском-языке)**

---

<a name="english-documentation"></a>
## 🇬🇧 English Documentation

### Overview

This project provides the **first complete, production-ready TR-069 (CWMP) + STUN + TR-181 (BBFDM Microservices) stack with a native LuCI Web Interface (`luci-app-cwmp`)** for **OpenWrt 25.12+** (`apk` package manager).

Originally developed and tested for ISP deployments with **GenieACS**, it turns modern OpenWrt routers (such as Xiaomi AX3000T, Redmi AX6000, GL.iNet Flint 2, Cudy WR3000, Asus TUF-AX4200, and other MediaTek Filogic `aarch64_cortex-a53` devices) into fully managed carrier-grade CPEs.

### Key Features

1. **Native LuCI Graphical Interface (`luci-app-cwmp`)**
   - Integrated directly into **LuCI → Services → TR-069 (CWMP)**.
   - **ACS Server Tab:** Configure ACS URL (`http://...` or `https://...`), ACS Username/Password, Periodic Inform Enable, Periodic Inform Interval, and WAN interface binding.
   - **CPE Client Tab:** Enable/disable CWMP daemon, configure incoming Connection Request Username, Password, Port (`7547`), and Log Level.
   - **STUN (NAT Traversal) Tab:** Enable/disable `stunc`, set STUN Server address, Port (`3478`), Username/Password, and KeepAlive interval so the ACS can trigger instant Connection Requests (`Summon`) even when the router is behind carrier-grade NAT (CGNAT).
   - Full `ucitrack` & `rpcd` ACL integration: clicking **Save & Apply** in LuCI automatically applies changes and restarts `icwmpd` and `stunc`.

2. **Complete TR-181 (`Device.*`) BBFDM Microservice Stack**
   - Includes `bbfdmd`, `dm-service`, `icwmp`, `stunc`, and all essential domain managers:
     - `sysmngr` (`Device.DeviceInfo.*`, `Device.Time.*`)
     - `netmngr` (`Device.IP.*`, `Device.PPP.*`, `Device.Routing.*`, `Device.NAT.*`)
     - `ethmngr` (`Device.Ethernet.*`)
     - `wifimngr` (`Device.WiFi.*`)
     - `dhcpmngr` (`Device.DHCPv4.*`, `Device.DHCPv6.*`)
     - `hostmngr` (`Device.Hosts.*` — connected LAN & Wi-Fi clients with signal/MAC/IP)

3. **ISP-Friendly Patches Included in Prebuilt Packages**
   - **`libbbfdm-api1.0` Patch (CWMP Password Visibility):** By default, IOPSYS BBFDM hides parameters marked with `DM_FLAG_SECURE` (such as Wi-Fi `KeyPassphrase` and PPPoE passwords), returning an empty string `""` to the ACS. Our patched `libbbfdm-api1.0` allows CWMP (`PROTO_CWMP`) to read and manage Wi-Fi passwords in GenieACS.
   - **`wifimngr` Patch (Unified `Device.WiFi.SSID.{i}` Table):** Exposes `KeyPassphrase`, `SSIDAdvertisementEnabled`, `OperatingFrequencyBand`, `Standard`, `Channel`, and `AutoChannelEnable` directly under `Device.WiFi.SSID.{i}` so ACS dashboards (like GenieACS) can display and edit all Wi-Fi parameters in a single table row per band (2.4 GHz & 5 GHz).
   - **Automatic Factory Board Data Extraction:** Automatically populates `/etc/board-db/config/device` from factory NVRAM/`Bdata` (`/dev/mtd2`) so the router reports its true factory `SerialNumber`, `Manufacturer`, `ProductClass`, and `BaseMacAddr`.

4. **Remote Wake-on-LAN (WoL) Behind CGNAT via TR-069 & STUN**
   - Includes `scripts/tr069-wol.sh`, which hooks into `Device.DeviceInfo.ProvisioningCode` (`cwmp.cpe.provisioning_code`).
   - Writing a target PC's MAC address (e.g., `AA:BB:CC:DD:EE:FF`) to `Device.DeviceInfo.ProvisioningCode` from GenieACS triggers an instant Connection Request over STUN, wakes up the LAN PC via `etherwake` on `br-lan`, and reports back `WOL_OK:AA:BB:CC:DD:EE:FF`.

---

### Repository Structure

```text
├── install.sh                                      # 1-command installer for OpenWrt 25.12+
├── luci-app-cwmp/
│   ├── htdocs/luci-static/resources/view/cwmp.js   # LuCI client-side view (Services -> TR-069)
│   └── root/usr/share/
│       ├── luci/menu.d/luci-app-cwmp.json          # LuCI menu registration
│       └── rpcd/acl.d/luci-app-cwmp.json           # ubus / rpcd permissions for uci cwmp & stunc
├── packages/aarch64_cortex-a53/                    # Prebuilt OpenWrt 25.12 .apk packages (18 pkgs)
└── scripts/
    └── tr069-wol.sh                                # Wake-on-LAN via TR-069 ProvisioningCode hook
```

---

### Supported Devices

The prebuilt `.apk` packages in `packages/aarch64_cortex-a53/` target **OpenWrt 25.12+** on **`aarch64_cortex-a53`** (MediaTek Filogic 820 / 830 / MT7981 / MT7986, Qualcomm IPQ, etc.), including:
- **Xiaomi Mi Router AX3000T (`RD03`)**
- **Xiaomi Redmi Router AX6000**
- **GL.iNet GL-MT6000 (Flint 2) / GL-MT3000 (Beryl AX)**
- **Cudy WR3000 / TR3000**
- **Asus TUF-AX4200 / TUF-AX6000**
- **Banana Pi BPI-R3 / BPI-R3 Mini**

*(Note: `luci-app-cwmp` itself is pure JavaScript/JSON and is **architecture-independent** — it works on any OpenWrt 21.02 / 22.03 / 23.05 / 24.10 / 25.12 router that uses `icwmp` and `stunc`).*

---

### Quick Installation

Run the following commands on your OpenWrt 25.12 router via SSH:

```sh
cd /tmp
wget -O main.tar.gz https://github.com/Kreativbala/openwrt-tr069-cwmp-luci/archive/refs/heads/main.tar.gz
tar -xzf main.tar.gz
cd openwrt-tr069-cwmp-luci-main
sh install.sh
```

Or if `git` is installed on the router:

```sh
git clone https://github.com/Kreativbala/openwrt-tr069-cwmp-luci.git /tmp/tr069
sh /tmp/tr069/install.sh
```

After installation:
1. Log in to **LuCI** (`http://192.168.1.1`) → **Services → TR-069 (CWMP)**.
2. Enter your **ACS URL** (e.g. `http://acs.example.com:7547`), credentials, and STUN settings.
3. Click **Save & Apply**.

---

### Enabling Wake-on-LAN Behind NAT via TR-069 (Optional)

If you want to wake up computers on your home LAN remotely from your ACS (even behind CGNAT):

```sh
apk update && apk add etherwake luci-app-wol
cp /tmp/openwrt-tr069-cwmp-luci-main/scripts/tr069-wol.sh /usr/bin/tr069-wol.sh
chmod +x /usr/bin/tr069-wol.sh
sed -i '/^for uci in/i /usr/bin/tr069-wol.sh &' /etc/bbfdm/bbf_default_reload.sh
```

Then in GenieACS, set `Device.DeviceInfo.ProvisioningCode` to the target PC's MAC address (`AA:BB:CC:DD:EE:FF`) and commit.

---
---

<a name="документация-на-русском-языке"></a>
## 🇷🇺 Документация на русском языке

### О проекте

Это **первый полноценный готовый стек TR-069 (CWMP) + STUN + TR-181 (микросервисы BBFDM) с графическим веб-интерфейсом для LuCI (`luci-app-cwmp`)** под **OpenWrt 25.12+** (пакетный менеджер `apk`).

Проект разработан и протестирован для интернет-провайдеров и домашних пользователей, использующих **GenieACS** и другие ACS-серверы. Он превращает современные роутеры с OpenWrt (Xiaomi AX3000T, Redmi AX6000, Cudy WR3000, GL.iNet MT6000 и др. на базе `aarch64_cortex-a53` / MediaTek Filogic) в полностью управляемые операторские устройства с поддержкой работы за NAT.

---

### Основные возможности

1. **Графический интерфейс в LuCI (`luci-app-cwmp`)**
   - Появляется прямо в меню **LuCI → Услуги (Services) → TR-069 (CWMP)**.
   - **Вкладка «Сервер ACS»:** URL сервера (`http://...` или `https://...`), логин и пароль для авторизации на ACS, включение и интервал периодических отчётов (Periodic Inform), выбор WAN-интерфейса.
   - **Вкладка «Клиент CPE (Роутер)»:** включение/отключение клиента, логин и пароль для входящих запросов от сервера (Connection Request), порт (`7547`), уровень детализации логов.
   - **Вкладка «STUN (Работа за NAT)»:** включение STUN-клиента (`stunc`), адрес STUN-сервера, порт (`3478`), логин/пароль и интервал KeepAlive. Позволяет серверу ACS мгновенно опрашивать роутер (кнопка `Summon` в GenieACS) даже за «серым» IP провайдера (CGNAT).
   - Полная интеграция с `ucitrack` и `rpcd`: при нажатии **«Сохранить и применить»** в LuCI настройки автоматически применяются и перезапускают службы `icwmpd` и `stunc`.

2. **Полный стек микросервисов TR-181 (`Device.*`) BBFDM**
   - Включает ядро `bbfdmd`, `dm-service`, `icwmp`, `stunc` и все модули данных:
     - `sysmngr` (`Device.DeviceInfo.*`, `Device.Time.*` — аптайм, серийный номер, версия ПО, загрузка)
     - `netmngr` (`Device.IP.*`, `Device.PPP.*`, `Device.Routing.*`, `Device.NAT.*` — WAN/LAN IP и PPPoE сессии)
     - `ethmngr` (`Device.Ethernet.*` — статус, скорость и дуплекс LAN/WAN портов)
     - `wifimngr` (`Device.WiFi.*` — управление точками доступа и радиомодулями 2.4 / 5 ГГц)
     - `dhcpmngr` (`Device.DHCPv4.*`, `Device.DHCPv6.*` — настройки DHCP сервера и аренды)
     - `hostmngr` (`Device.Hosts.*` — список подключённых проводных и Wi-Fi клиентов с их IP, MAC и уровнем сигнала)

3. **Уникальные патчи для провайдеров (уже встроены в пакеты `.apk`)**
   - **Патч `libbbfdm-api1.0` (Чтение паролей Wi-Fi и PPPoE через CWMP):** по умолчанию библиотека IOPSYS BBFDM скрывает параметры с флагом `DM_FLAG_SECURE`, отдавая пустую строку `""` вместо пароля Wi-Fi. Наш патч разрешает протоколу CWMP (`PROTO_CWMP`) читать и менять пароли Wi-Fi прямо из карточки абонента в GenieACS.
   - **Патч `wifimngr` (Единая таблица Wi-Fi в `Device.WiFi.SSID.{i}`):** добавляет параметры `KeyPassphrase`, `SSIDAdvertisementEnabled`, `OperatingFrequencyBand`, `Standard`, `Channel` и `AutoChannelEnable` напрямую в ветку `Device.WiFi.SSID.{i}`. Благодаря этому в GenieACS все настройки 2.4 ГГц и 5 ГГц (имя сети, пароль, канал, частота, стандарт, скрытие SSID) отображаются и редактируются в одной удобной таблице.
   - **Автоматическое чтение заводских данных (`Bdata`):** скрипт установки автоматически извлекает настоящий заводской серийный номер (`SN`), MAC-адрес и модель из раздела `/dev/mtd2` (`Bdata`) и записывает их в `/etc/board-db/config/device`.

4. **Wake-on-LAN (Включение домашнего ПК) за «серым» IP / CGNAT через TR-069**
   - В комплект входит скрипт `scripts/tr069-wol.sh`, который отслеживает параметр `Device.DeviceInfo.ProvisioningCode`.
   - Если у вас дома «серый» IP (CGNAT) и проброс портов невозможен, вы просто заходите в GenieACS, вписываете MAC-адрес домашнего компьютера (например, `AA:BB:CC:DD:EE:FF`) в поле `Wake on LAN` (`Device.DeviceInfo.ProvisioningCode`) — сервер через STUN мгновенно передаёт команду роутеру, роутер посылает **Magic Packet** (`etherwake`) в локальную сеть `br-lan`, включает компьютер и возвращает статус `WOL_OK:AA:BB:CC:DD:EE:FF`.

---

### Быстрая установка (в 1 команду)

Подключитесь к роутеру по SSH (`ssh root@192.168.1.1`) и выполните:

```sh
cd /tmp
wget -O main.tar.gz https://github.com/Kreativbala/openwrt-tr069-cwmp-luci/archive/refs/heads/main.tar.gz
tar -xzf main.tar.gz
cd openwrt-tr069-cwmp-luci-main
sh install.sh
```

Скрипт `install.sh` автоматически:
1. Установит все 18 пакетов `.apk` из папки `packages/aarch64_cortex-a53/`.
2. Установит веб-интерфейс `luci-app-cwmp` в LuCI.
3. Пропишет заводской серийный номер и MAC-адрес роутера для TR-069.
4. Перезапустит службы `bbfdmd`, `stunc`, `icwmpd` и веб-сервер `uhttpd`.

После этого откройте браузер: **`http://192.168.1.1` → Услуги (Services) → TR-069 (CWMP)**.

---

### Подключение Wake-on-LAN через TR-069 (опционально)

Чтобы будить компьютеры в локальной сети через GenieACS (даже за NAT провайдера):

```sh
apk update && apk add etherwake luci-app-wol luci-i18n-wol-ru
cp /tmp/openwrt-tr069-cwmp-luci-main/scripts/tr069-wol.sh /usr/bin/tr069-wol.sh
chmod +x /usr/bin/tr069-wol.sh
sed -i '/^for uci in/i /usr/bin/tr069-wol.sh &' /etc/bbfdm/bbf_default_reload.sh
```

---

### Лицензия / License

Распространяется под открытой лицензией **GNU General Public License v2.0 (GPL-2.0)**. Вы можете свободно использовать, модифицировать и распространять этот проект.
