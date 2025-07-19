#!/bin/bash
set -e

echo "[INFO] Decoding playit.toml from GitHub secret..."
echo "$PLAYIT_TOML" | base64 -d > playit.toml

echo "[INFO] Downloading playit.gg Linux binary..."
wget -qO playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
chmod +x playit

echo "[INFO] Starting playit.gg tunnel agent in background..."
nohup ./playit &> playit.log &
sleep 5
head -20 playit.log

echo "[INFO] Starting SA-MP server..."
cd server
chmod +x samp03svr
./samp03svr &
SAMP_PID=$!
cd ..

echo "[INFO] Server running. Sleeping for 315 minutes."
sleep 315m

echo "[INFO] Stopping SA-MP server..."
kill -SIGINT $SAMP_PID
wait $SAMP_PID
echo "[INFO] SA-MP server stopped. Script complete."