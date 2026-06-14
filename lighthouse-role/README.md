# lighthouse-role

Ansible-роль для установки и настройки [LightHouse](https://github.com/VKCOM/lighthouse) через nginx.

LightHouse — это статический веб-интерфейс для работы с ClickHouse. Роль скачивает статические файлы LightHouse, размещает их в каталоге веб-сервера и настраивает nginx.

## Описание

Роль выполняет следующие действия:

- устанавливает `nginx` и необходимые пакеты;
- создаёт каталог для статических файлов LightHouse;
- скачивает архив LightHouse из репозитория `VKCOM/lighthouse`;
- распаковывает статику в целевой каталог;
- удаляет дефолтный сайт nginx;
- создаёт nginx-конфигурацию для LightHouse из шаблона;
- добавляет proxy location `/clickhouse/` до HTTP-интерфейса ClickHouse;
- включает и запускает systemd-сервис `nginx`.

Прокси `/clickhouse/` нужен для удобной работы браузера с ClickHouse, особенно когда ClickHouse находится во внутренней сети и недоступен напрямую с локальной машины.

## Требования

### Требования к управляющей машине

- Ansible `>= 2.10`.

### Требования к управляемому хосту

Роль рассчитана на хосты семейства Debian/Ubuntu, где доступны:

- пакетный менеджер `apt`;
- `systemd`;
- структура nginx с каталогами:
  - `/etc/nginx/sites-available`;
  - `/etc/nginx/sites-enabled`;
- доступ в интернет для скачивания архива LightHouse;
- права повышения привилегий через `become: true`.

### Сетевые требования

Хост с LightHouse должен иметь сетевой доступ к HTTP-порту ClickHouse:

```text
LightHouse host -> ClickHouse host:8123
```

Для доступа пользователей к LightHouse должен быть открыт HTTP-порт nginx, по умолчанию `80/tcp`.

## Переменные роли

### Основные переменные

Эти переменные находятся в `defaults/main.yml` и могут переопределяться в playbook, inventory или `group_vars`.

| Переменная                   | Значение по умолчанию                                                  | Описание                                  |
|------------------------------|------------------------------------------------------------------------|-------------------------------------------|
| `lighthouse_root`            | `/var/www/lighthouse`                                                  | Каталог для статических файлов LightHouse |
| `lighthouse_archive_url`     | `https://github.com/VKCOM/lighthouse/archive/refs/heads/master.tar.gz` | URL архива LightHouse                     |
| `lighthouse_archive_dest`    | `/tmp/lighthouse-master.tar.gz`                                        | Локальный путь для скачанного архива      |
| `lighthouse_server_name`     | `_`                                                                    | Значение `server_name` в nginx            |
| `lighthouse_listen_port`     | `80`                                                                   | HTTP-порт nginx                           |
| `lighthouse_clickhouse_host` | `127.0.0.1`                                                            | IP-адрес или DNS-имя ClickHouse           |
| `lighthouse_clickhouse_port` | `8123`                                                                 | HTTP-порт ClickHouse                      |

### Внутренние переменные

Эти переменные находятся в `vars/main.yml`. 

| Переменная                         |  Описание                          |
|------------------------------------|------------------------------------|
| `lighthouse_nginx_package`         | Имя пакета nginx                   |
| `lighthouse_nginx_service`         | Имя systemd-сервиса nginx          |
| `lighthouse_nginx_sites_available` | Каталог `sites-available`          |
| `lighthouse_nginx_sites_enabled`   | Каталог `sites-enabled`            |
| `lighthouse_nginx_default_site`    | Путь к дефолтному сайту nginx      |
| `lighthouse_nginx_config_name`     | Имя конфигурации сайта LightHouse  |

## Зависимости

У роли нет зависимостей от других Ansible-ролей.

Для корректной работы LightHouse должен быть доступен ClickHouse. В основном playbook ClickHouse устанавливается отдельной ролью, а адрес ClickHouse передаётся в переменную `lighthouse_clickhouse_host`.

## Пример playbook

```yaml
---
- name: Install LightHouse
  hosts: lighthouse
  become: true
  roles:
    - role: lighthouse-role
      vars:
        lighthouse_clickhouse_host: "{{ hostvars[groups['clickhouse'][0]].private_ip }}"
        lighthouse_clickhouse_port: 8123
```

## Пример с тегом

```yaml
---
- name: Install LightHouse
  hosts: lighthouse
  become: true
  roles:
    - role: lighthouse-role
      tags:
        - lighthouse
```

Запуск только роли LightHouse:

```bash
ansible-playbook -i prod.yml site.yml --tags lighthouse
```

