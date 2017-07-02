#!/bin/sh

echo "[i] Starting elasticsearch"
/scripts/run-es.sh &
echo "[i] Run create indexes"
/scripts/init.sh
echo "[i] Starting kibana"
/opt/kibana/bin/kibana &
echo "[i] Starting logstash"
/opt/$LOGSTASH_NAME-$LOGSTASH_VERSION/bin/logstash -f /etc/$LOGSTASH_NAME/$LOGSTASH_NAME.json