# Safety Map Checklist

Используй это, если система выглядит хрупкой или интеграционно тяжёлой и слепой рефакторинг может что-то уронить.

## Что собрать перед изменениями

1. Callers and consumers:
   кто вызывает API, CLI, webhooks, jobs или читает экспортируемые файлы.
2. Shared files and paths:
   какие папки, DBF/CSV/JSON, inbox/outbox, network shares или config paths являются внешним контрактом.
3. Data contracts:
   какие форматы, поля, имена файлов, env-переменные, таблицы или очереди нельзя ломать без миграции.
4. Machine and service dependencies:
   какие компы, VPS, кассы, cron, systemd, плагины, батники или сторонние сервисы завязаны на текущую схему.
5. Failure surface:
   что сломается первым, если путь, формат, порт, endpoint или имя файла изменится.

## Короткий output shape

```md
## Contracts
- callers:
- shared files:
- env/config:
- machines/services:
- first breakage risk:
```

Если карта получилась длинной, положи её во временный файл в `runtime/research/<repo-slug>/contracts.md`, а в ответ вынеси только сжатую версию.
