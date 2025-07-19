#!/bin/bash
set -e


echo "[INFO] Decoding playit.toml from GitHub secret..."
echo "$PLAYIT_TOML" | base64 -d > playit.toml
echo "[INFO] playit.toml decoded."


echo "[INFO] Downloading playit.gg Linux binary..."
wget -qO playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
chmod +x playit
echo "[INFO] playit.gg binary ready."



echo "🌐 playit.gg agent started. Connect using the tunnel address above!"


echo "[INFO] Starting playit.gg tunnel agent in background..."
nohup ./playit &> ../playit.log &
sleep 5
echo "[INFO] playit.gg agent started. Tunnel info below:"
head -20 ../playit.log





echo "[INFO] Setting up named pipe for SA-MP server console input..."
pushd server > /dev/null
chmod +x samp03svr
PIPE=samp.pipe
if [[ -p $PIPE ]]; then
  echo "[WARN] Removing stale pipe $PIPE."
  rm -f $PIPE
fi
if ! mkfifo $PIPE; then
  echo "[ERROR] Failed to create named pipe $PIPE! Exiting."
  exit 1
fi

echo "[INFO] Starting SA-MP server with PTY for pipe input..."
script -q -c "./samp03svr" /dev/null < $PIPE &
SAMP_PID=$!
sleep 2
if ! ps -p $SAMP_PID > /dev/null; then
  echo "[ERROR] SA-MP server failed to start! Exiting."
  rm -f $PIPE
  popd > /dev/null
  exit 1
fi
echo "[INFO] SA-MP server started with PID $SAMP_PID."
popd > /dev/null



echo "[INFO] Server running. Sleeping for 315 minutes before restart warnings."
sleep 315m


echo "[INFO] Sending restart warnings to players."

for i in 5 4 3 2 1; do
  if [[ ! -p server/samp.pipe ]]; then
    echo "[ERROR] Pipe server/samp.pipe missing during warning!"
    break
  fi
  echo "say SERVER: Restart in $i minute(s)!" > server/samp.pipe
  sleep 60
done



if [[ -p server/samp.pipe ]]; then
  echo "say SERVER: Restarting now!" > server/samp.pipe
else
  echo "[WARN] Pipe server/samp.pipe missing at shutdown."
fi
echo "[INFO] Stopping SA-MP server..."
kill -SIGINT $SAMP_PID
wait $SAMP_PID
echo "[INFO] SA-MP server stopped. Cleaning up pipe."
rm -f server/samp.pipe
echo "[INFO] Script complete."
