# Code Review Contract

Этот репозиторий — переносимый context pack, а не приложение. Тут важнее целостность структуры, правил и discovery-слоёв, чем обычная app-логика.

## На что смотреть первым делом

1. Сломанные ссылки, обязательные файлы и любые регрессии, которые валидатор должен был поймать.
2. Второй источник истины: дубли между `AGENTS.md`, `README.md`, `skills/`, `.agents/skills/`, шаблонами и workflow-файлами.
3. Целостность skill-слоя: битый front matter, пропавший `agents/openai.yaml`, рассинхрон wrapper-ов в `.agents/skills/` с каноном в `skills/`, слишком общие новые имена навыков.
4. Operational-риски: CI, завязанный на локальную машину; опасные sandbox/approval изменения; portability-регрессии.
5. Утечки: секреты, `.env`, machine-local пути, случайно закоммиченные payload-ы из `runtime/`.
6. Ложные или устаревшие routing/rules-инструкции для subagents, review и verification.

## Формат ответа

- Findings first.
- По серьёзности сверху вниз.
- С tight file refs.
- Если находок нет, так и напиши, потом одной короткой фразой укажи остаточный риск или testing gap.
- Не хвали PR и не пересказывай diff без причины.

## Ожидаемая проверка

```powershell
powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```
