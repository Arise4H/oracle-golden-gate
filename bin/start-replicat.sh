#!/bin/bash
echo "Starting Cassandra Replicat..."
${OGG_HOME}/ggsci <<EOF
START REPLICAT repcass
INFO REPLICAT repcass
EOF
tail -f /dev/null
