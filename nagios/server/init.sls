{% from "nagios/map.jinja" import map with context %}

nagios-server-package:
  pkg:
    - installed
    - name: {{ map.nagios_server }}

nagios-service:
  service:
    - running
    - name: {{ map.nagios_service }}
    - enable: true

nagios-server-config:
  file:
    - managed
    - name: {{ map.nagios_config_dir }}/nagios.cfg
    - source: salt://nagios/server/files/nagios.cfg
    - template: jinja
    - watch_in:
      - service: {{ map.nagios_service }}

nagios-cgi-config:
  file:
    - managed
    - name: {{ map.nagios_config_dir }}/cgi.cfg
    - source: salt://nagios/server/files/cgi.cfg
    - template: jinja

nagios-resource-config:
  file:
    - managed
    - name: {{ map.nagios_resource_file }}
    - source: salt://nagios/server/files/resource.cfg
    - template: jinja

{% if grains['os_family'] == 'Arch' %}
nagios-group:
  group:
    - present
    - name: nagios
    - system: true
    - gid: 31

nagios-user:
  user:
    - present
    - name: nagios
    - shell: /bin/false
    - home: /usr/share/nagios
    - gid_from_name: true
    - system: true
    - uid: 31
    - guid: 31

nagios-server-log:
  file.managed:
    - name: {{ map.nagios_server_log }}
    - user: root
    - group: nagios
    - mode: 660
    - makedirs: True
    - require:
      - group: nagios-group

extend:
  nagios-server-config:
    - file:
      - user: nagios
      - group: nagios
  nagios-cgi-config:
    - file:
      - user: nagios
      - group: nagios
  nagios-resource-config:
    - file:
      - user: nagios
      - group: nagios
{% endif %}
