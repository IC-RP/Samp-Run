#!/bin/bash
set -e

# ✉️ Decode playit.toml from GitHub secret
echo "$PLAYIT_TOML" | base64 -d > playit.toml

# 🔧 Download the official playit.gg Linux binary
wget -qO playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
chmod +x playit



echo "🌐 playit.gg agent started. Connect using the tunnel address above!"

# ▶️ Launch playit.gg in background to establish UDP tunnel, suppress output
nohup ./playit &> ../playit.log &

# 🕒 Wait a few seconds for tunnel to initialize
sleep 5

# ▶️ Show Playit tunnel address ONCE in GitHub Actions logs
echo "🌐 playit.gg agent started. Tunnel info below:"
head -20 ../playit.log



# 🛠️ Set up named pipe for SA-MP server console input
cd server
chmod +x samp03svr
PIPE=samp.pipe
if [[ ! -p $PIPE ]]; then
  rm -f $PIPE
  mkfifo $PIPE
fi

# Start the server, reading input from the pipe
./samp03svr < $PIPE &
SAMP_PID=$!
cd ..


# 🕒 Let the server run for the workflow duration minus warning period (5 min)
sleep 315m

# ⏰ Send warnings to all players before shutdown using RCON
for i in 5 4 3 2 1; do
  echo "say SERVER: Restart in $i minute(s)!" > server/samp.pipe
  sleep 60
done

# ⏹️ Gracefully stop the SA-MP server before workflow ends
echo "say SERVER: Restarting now!" > server/samp.pipe
echo "Stopping SA-MP server..."
kill -SIGINT $SAMP_PID

# Wait for the server to exit
wait $SAMP_PID
