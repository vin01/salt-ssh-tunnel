{%- macro ssh_tunnel_user(fullname, username, ssh_pubkey) %}
{{ username }}:
  user.present:
    - fullname: {{ fullname }}
    - shell: /bin/bash
    - home: /home/{{ username }}

/home/{{ username }}/.ssh:
  file.directory:
    - user: {{ username }}
    - group: {{ username }}
    - mode: 755
    - require:
      - user: {{ username }}

/home/{{ username }}/.ssh/authorized_keys:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - mode: 644
    - contents:
      # Allow SSH tunneling to 1.postgresql.reporting only
      - no-pty,no-user-rc,no-agent-forwarding,no-X11-forwarding,permitopen="{{ pillar['ssh-tunnel']['remote_host'] }}",command="/bin/echo do-not-send-commands" {{ ssh_pubkey }}
    - require:
      - user: {{ username }}
{%- endmacro %}

{% for username, attr in pillar['ssh-tunnel']['users'].items() %}
{{ ssh_tunnel_user(attr['name'], username, attr['pubkey']) }}
{% endfor %}
