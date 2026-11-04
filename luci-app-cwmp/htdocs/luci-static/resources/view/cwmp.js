'use strict';
'require view';
'require form';
'require uci';
'require fs';
'require ui';

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('cwmp'),
			uci.load('stunc')
		]);
	},

	render: function() {
		var m, s, o;

		m = new form.Map('cwmp', _('TR-069 / CWMP Клиент (icwmp)'),
			_('Настройка протокола удалённого управления провайдера TR-069 (CWMP) и STUN-клиента для работы за NAT.'));
		m.chain('stunc');

		// 1. ACS Server Settings
		s = m.section(form.NamedSection, 'acs', 'acs', _('Настройки сервера ACS'));
		s.addremove = false;

		o = s.option(form.Value, 'url', _('ACS URL (Адрес сервера)'));
		o.placeholder = 'http://acs.mega.kg:7547';
		o.rmempty = false;

		o = s.option(form.Value, 'userid', _('Логин ACS (Username)'));
		o.placeholder = 'mega';

		o = s.option(form.Value, 'passwd', _('Пароль ACS (Password)'));
		o.password = true;

		o = s.option(form.Flag, 'periodic_inform_enable', _('Периодический опрос (Periodic Inform)'));
		o.default = '1';
		o.rmempty = false;

		o = s.option(form.Value, 'periodic_inform_interval', _('Интервал опроса (сек)'));
		o.datatype = 'uinteger';
		o.placeholder = '300';

		o = s.option(form.ListValue, 'dhcp_discovery', _('Получать адрес ACS по DHCP (Опция 43)'));
		o.value('enable', _('Включено'));
		o.value('disable', _('Отключено'));
		o.default = 'disable';

		o = s.option(form.ListValue, 'compression', _('HTTP-сжатие'));
		o.value('Disabled', _('Отключено'));
		o.value('GZIP', 'GZIP');
		o.value('Deflate', 'Deflate');
		o.default = 'Disabled';

		// 2. CPE Settings
		s = m.section(form.NamedSection, 'cpe', 'cpe', _('Настройки устройства (CPE / Connection Request)'));
		s.addremove = false;

		o = s.option(form.Flag, 'enable', _('Включить службу TR-069 (icwmpd)'));
		o.default = '1';
		o.rmempty = false;

		o = s.option(form.Value, 'default_wan_interface', _('WAN-интерфейс'));
		o.placeholder = 'wan';

		o = s.option(form.Value, 'port', _('Порт входящих запросов (Connection Request Port)'));
		o.datatype = 'port';
		o.placeholder = '7547';

		o = s.option(form.Value, 'userid', _('Логин Connection Request'));
		o.placeholder = 'mega';

		o = s.option(form.Value, 'passwd', _('Пароль Connection Request'));
		o.password = true;

		o = s.option(form.Value, 'manufacturer', _('Производитель (Manufacturer)'));
		o.placeholder = 'Xiaomi';

		o = s.option(form.Value, 'manufacturer_oui', _('OUI производителя'));
		o.placeholder = 'CCD843';

		o = s.option(form.Value, 'product_class', _('Класс устройства (ProductClass)'));
		o.placeholder = 'RD03';

		o = s.option(form.Value, 'serial_number', _('Серийный номер (SerialNumber)'));

		o = s.option(form.ListValue, 'log_severity', _('Уровень логирования'));
		o.value('EMERG', 'EMERG');
		o.value('ALERT', 'ALERT');
		o.value('CRIT', 'CRIT');
		o.value('ERROR', 'ERROR');
		o.value('WARNING', 'WARNING');
		o.value('NOTICE', 'NOTICE');
		o.value('INFO', 'INFO');
		o.value('DEBUG', 'DEBUG');
		o.default = 'INFO';

		// 3. STUN Client Settings (from /etc/config/stunc)
		s = m.section(form.NamedSection, 'stunc', 'stunc', _('Настройки STUN (Обход NAT для TR-069)'));
		s.uciconfig = 'stunc';
		s.addremove = false;

		o = s.option(form.Flag, 'enabled', _('Включить STUN-клиент'));
		o.default = '1';
		o.rmempty = false;

		o = s.option(form.Value, 'server_address', _('Адрес STUN-сервера'));
		o.placeholder = '77.235.14.31';

		o = s.option(form.Value, 'server_port', _('Порт STUN-сервера'));
		o.datatype = 'port';
		o.placeholder = '3478';

		o = s.option(form.Value, 'username', _('Логин STUN'));
		o.placeholder = 'mega';

		o = s.option(form.Value, 'password', _('Пароль STUN'));
		o.password = true;

		o = s.option(form.Value, 'min_keepalive', _('Мин. интервал KeepAlive (сек)'));
		o.datatype = 'uinteger';
		o.placeholder = '30';

		o = s.option(form.Value, 'max_keepalive', _('Макс. интервал KeepAlive (сек)'));
		o.datatype = 'uinteger';
		o.placeholder = '120';

		return m.render();
	}
});
