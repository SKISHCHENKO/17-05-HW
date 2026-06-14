# Домашнее задание к занятию 4 «Работа с roles»

## Описание

Проект является продолжением домашнего задания `17-03-HW`. <https://github.com/SKISHCHENKO/17-03-HW>

В предыдущей версии playbook напрямую содержал tasks для установки:

- ClickHouse;
- Vector;
- LightHouse + nginx.

В этой версии playbook переработан на использование Ansible roles:

- `clickhouse` — внешняя роль `AlexeySetevoi/ansible-clickhouse`, версия `1.13`;
- `vector-role` — собственная роль для установки и настройки Vector;
- `lighthouse-role` — собственная роль для установки и настройки LightHouse через nginx.

Terraform-часть сохранена: она создаёт три ВМ в Yandex Cloud и автоматически формирует `ansible/prod.yml` из фактических публичных и приватных IP-адресов.

## Репозитории

- Vector role: <https://github.com/SKISHCHENKO/vector-role>
- LightHouse role: <https://github.com/SKISHCHENKO/lighthouse-role>
- Playbook: <https://github.com/SKISHCHENKO/17-04-HW>

## Структура проекта

```text
.
├── terraform
│   ├── ansible_inventory.tf
│   ├── instances.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── templates
│   │   └── prod.yml.tftpl
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   └── versions.tf
└── ansible
    ├── ansible.cfg
    ├── group_vars
    │   └── all.yml
    ├── prod.yml.example
    ├── requirements.yml
    └── site.yml
```

## requirements.yml

Файл `ansible/requirements.yml` содержит три роли:

```yaml
---
- src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
  scm: git
  version: "1.13"
  name: clickhouse

- src: git@github.com:SKISHCHENKO/vector-role.git
  scm: git
  version: "1.0.0"
  name: vector-role

- src: git@github.com:SKISHCHENKO/lighthouse-role.git
  scm: git
  version: "1.0.0"
  name: lighthouse-role
```

## Подготовка инфраструктуры

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

В `terraform.tfvars` нужно указать свой публичный SSH-ключ.

Далее:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

После `terraform apply` будет создан файл:

```text
ansible/prod.yml
```

Он генерируется автоматически из outputs Terraform.

## Установка ролей

```bash
cd ../ansible
ansible-galaxy install -r requirements.yml
```

Роли будут установлены в каталог:

```text
ansible/roles/
```

Этот каталог не коммитится в Git, потому что роли подтягиваются через `requirements.yml`.

## Проверка inventory

```bash
ansible-inventory -i prod.yml --list
ansible all -i prod.yml -m ping
```

Ожидаемый результат:

```text
clickhouse-01 | SUCCESS
vector-01     | SUCCESS
lighthouse-01 | SUCCESS
```

## Запуск ansible-lint

```bash
ansible-lint site.yml
```

## Check-mode

```bash
ansible-playbook -i prod.yml site.yml --check
```

## Запуск

```bash
ansible-playbook -i prod.yml site.yml --diff
```

## Повторный запуск для проверки идемпотентности

```bash
ansible-playbook -i prod.yml site.yml --diff
```

Во втором запуске большая часть задач должна быть `ok`, а не `changed`.


## Проверка сервисов

ClickHouse:

```bash
ansible clickhouse -i prod.yml -b -m service -a "name=clickhouse-server state=started"
ansible clickhouse -i prod.yml -m command -a "clickhouse-client --query 'SHOW DATABASES'"
```

Vector:

```bash
ansible vector -i prod.yml -b -m service -a "name=vector state=started"
ansible vector -i prod.yml -b -m command -a "vector validate /etc/vector/vector.yaml"
```

LightHouse:

```bash
ansible lighthouse -i prod.yml -b -m service -a "name=nginx state=started"
ansible lighthouse -i prod.yml -m uri -a "url=http://127.0.0.1/ status_code=200"
```

## Создание тегов

Для ролей используется семантическая нумерация:

```bash
git tag 1.0.0
git push origin 1.0.0
```

Для playbook-репозитория:

```bash
git tag 08-ansible-04-roles
git push origin 08-ansible-04-roles
```
