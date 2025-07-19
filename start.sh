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





echo "[INFO] Server running. Sleeping for 315 minutes before restart warnings."
sleep 315m
echo "[INFO] Sending restart warnings to players."
done

echo "[INFO] Starting SA-MP server normally (no pipe, no warnings)..."
pushd server > /dev/null
chmod +x samp03svr
./samp03svr &
SAMP_PID=$!
sleep 2
if ! ps -p $SAMP_PID > /dev/null; then
  echo "[ERROR] SA-MP server failed to start! Exiting."
  popd > /dev/null
  exit 1
fi
echo "[INFO] SA-MP server started with PID $SAMP_PID."
popd > /dev/null

echo "[INFO] Server running. Sleeping for 315 minutes."
sleep 315m

echo "[INFO] Stopping SA-MP server..."
kill -SIGINT $SAMP_PID
wait $SAMP_PID
echo "[INFO] SA-MP server stopped. Script complete."
