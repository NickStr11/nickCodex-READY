# WSL Migration

Если native Windows путь под OpenClaw начинает тупить, не ковыряй его вечно.
Быстрый fallback:

1. В PowerShell от администратора:

```powershell
wsl --install -d Ubuntu-24.04
```

2. После ребута включить `systemd` в WSL:

```bash
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
exit
```

Потом из Windows:

```powershell
wsl --shutdown
```

3. Держать код внутри WSL, а не в `/mnt/c`:

```bash
mkdir -p ~/code
cd ~/code
git clone --branch codex/openclaw-second-laptop-setup --single-branch https://github.com/NickStr11/nickCodex-READY.git
cd nickCodex-READY
```

4. Поставить Codex и OpenClaw внутри WSL:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
source ~/.bashrc
nvm install 22
npm i -g @openai/codex
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

5. Дальше обычный flow:

```bash
codex
openclaw onboard --auth-choice openai-codex --install-daemon
openclaw gateway status
openclaw dashboard
```

Источники:
- https://developers.openai.com/codex/windows/
- https://docs.openclaw.ai/platforms/windows
