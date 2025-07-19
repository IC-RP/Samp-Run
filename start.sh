#!/bin/bash
set -e

# ✉️ Decode playit.toml from GitHub secret
echo "$PLAYIT_TOML" | base64 -d > playit.toml

# 🔧 Download the official playit.gg Linux binary
wget -qO playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
chmod +x playit

# ▶️ Launch playit.gg in background to establish UDP tunnel
./playit &

# 🕒 Wait a few seconds for tunnel to initialize
sleep 5

echo "🌐 playit.gg agent started. Connect using the tunnel address above!"

# 🛠️ Start SA‑MP server
cd server
chmod +x samp03svr
./samp03svr
