#!/bin/bash

# Only run deployment script once if not already done
if [ ! -f "${OGG_HOME}/.deployment_done" ]; then
  echo "[INFO] Running GoldenGate deployment setup..."
  /usr/local/bin/deployment-main.sh
  touch "${OGG_HOME}/.deployment_done"
else
  echo "[INFO] Deployment already completed — skipping"
fi

# Start replicat
/usr/local/bin/start-replicat.sh