#!/system/bin/sh

LOG_FILE="/data/log_debug_venue8_3030.txt"
MAX_COLLECTS=3
INTERVAL_SECS_COLLECTS=60

/system/bin/date >> ${LOG_FILE}
echo "==== BEGIN ====" >> ${LOG_FILE}

v_counter=1
while [ ${v_counter} -le ${MAX_COLLECTS} ]
do
  /system/bin/date >> ${LOG_FILE}
  /system/bin/dmesg >> ${LOG_FILE}
  /system/bin/logcat -d >> ${LOG_FILE}
  echo "=======================================================================" >> ${LOG_FILE}
  v_counter=$((v_counter+1))
  /system/bin/sleep ${INTERVAL_SECS_COLLECTS}
done
