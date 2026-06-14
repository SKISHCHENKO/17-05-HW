# vector-role

Ansible-роль для установки и настройки [Vector](https://vector.dev/) на управляемом хосте Debian/Ubuntu-family.

Роль устанавливает Vector из актуального APT-репозитория, создаёт конфигурационный файл `/etc/vector/vector.yaml` из шаблона и запускает сервис `vector`.

## Описание

Роль выполняет следующие действия:

- устанавливает необходимые пакеты для работы с APT-репозиториями по HTTPS;
- удаляет старый репозиторий `repositories.timber.io`, если он был добавлен ранее;
- добавляет актуальный APT-репозиторий Vector `https://apt.vector.dev/`;
- устанавливает пакет `vector`;
- создаёт конфигурационный файл Vector из шаблона;
- включает и запускает systemd-сервис `vector`.

В текущей конфигурации Vector генерирует демонстрационные логи и отправляет их в ClickHouse через HTTP-интерфейс.

## Требования

### Требования к управляющей машине

- Ansible `>= 2.10`.

### Требования к управляемому хосту

Роль рассчитана на хосты семейства Debian/Ubuntu, где доступны:

- пакетный менеджер `apt`;
- `systemd`;
- доступ в интернет для скачивания ключей репозитория и пакетов;
- права повышения привилегий через `become: true`.

### Сетевые требования

Хост с Vector должен иметь сетевой доступ к HTTP-порту ClickHouse:

```text
Vector host -> ClickHouse host:8123
```

По умолчанию используется порт `8123`.

## Переменные роли

### Основные переменные

Эти переменные находятся в `defaults/main.yml` и могут переопределяться в playbook, inventory или `group_vars`.

| Переменная                   | Значение по умолчанию     | Описание                              |
|------------------------------|---------------------------|---------------------------------------|
| `vector_config_path`         | `/etc/vector/vector.yaml` | Путь к конфигурационному файлу Vector |
| `vector_clickhouse_host`     | `127.0.0.1`               | IP-адрес или DNS-имя ClickHouse       |
| `vector_clickhouse_port`     | `8123`                    | HTTP-порт ClickHouse                  |
| `vector_clickhouse_database` | `logs`                    | База данных ClickHouse для логов      |
| `vector_clickhouse_table`    | `vector_logs`             | Таблица ClickHouse для логов          |
| `vector_demo_logs_interval`  | `1`                       | Интервал генерации demo logs          |
| `vector_skip_unknown_fields` | `true`                    | Игнорировать неизвестные поля при записи в ClickHouse |
| `vector_compression`         | `gzip`                    | Тип сжатия для ClickHouse sink        |

### Внутренние переменные

Эти переменные находятся в `vars/main.yml`. 

| Переменная                  | Описание                             |
|-----------------------------|--------------------------------------|
| `vector_service_name`       | Имя systemd-сервиса Vector           |
| `vector_package_name`       | Имя устанавливаемого пакета          |
| `vector_repository_keyring` | Путь к keyring-файлу APT-репозитория |
| `vector_repository_url`     | URL APT-репозитория Vector           |
| `vector_repository`         | Строка APT-репозитория               |
| `vector_repository_keys`    | Список GPG-ключей репозитория        |

## Зависимости

У роли нет зависимостей от других Ansible-ролей.

Для корректной работы итоговой схемы должен быть заранее установлен и доступен ClickHouse. В основном playbook это решается отдельной ролью `clickhouse`.

## Пример playbook

```yaml
---
- name: Install Vector
  hosts: vector
  become: true
  roles:
    - role: vector-role
      vars:
        vector_clickhouse_host: "{{ hostvars[groups['clickhouse'][0]].private_ip }}"
        vector_clickhouse_port: 8123
        vector_clickhouse_database: logs
        vector_clickhouse_table: vector_logs
```

## Пример с тегом

```yaml
---
- name: Install Vector
  hosts: vector
  become: true
  roles:
    - role: vector-role
      tags:
        - vector
```

Запуск только роли Vector:

```bash
ansible-playbook -i prod.yml site.yml --tags vector
```

## Проверка

После выполнения роли можно проверить состояние сервиса:

```bash
systemctl status vector --no-pager
```

Проверить конфигурацию Vector:

```bash
vector validate /etc/vector/vector.yaml
```

Проверить, что данные попадают в ClickHouse:

```bash
curl "http://CLICKHOUSE_HOST:8123/?query=SELECT%20count()%20FROM%20logs.vector_logs"
```

