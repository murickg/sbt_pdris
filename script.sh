#!/bin/bash

# Путь к PID файлу
PIDFILE="/tmp/disk_monitor.pid"

# Функция для мониторинга дискового пространства и inodes
monitor_disk() {
    while true; do
        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        FILENAME="disk_usage_$TIMESTAMP.csv"

        #df -h --output=source,size,used,avail,pcent,target > "$FILENAME"
        #df -ih --output=source,itotal,iused,iavail,ipcent,target >> "$FILENAME"
        df -h | awk 'NR==1 || /^\/dev\//' > "$FILENAME"
        df -ih | awk 'NR==1 || /^\/dev\//' >> "$FILENAME"

        sleep 60

        NEW_DAY=$(date +"%Y-%m-%d")
        if [[ "$NEW_DAY" != "$CURRENT_DAY" ]]; then
            CURRENT_DAY="$NEW_DAY"
        fi
    done
}

#Статусы скрипта
start_monitoring() {
    if [[ -f $PIDFILE ]]; then
        echo "Монитор уже запущен. PID: $(cat $PIDFILE)"
        exit 1
    fi

    CURRENT_DAY=$(date +"%Y-%m-%d")
    monitor_disk &
    PID=$!
    echo $PID > "$PIDFILE"
    echo "Мониторинг запущен. PID: $PID"
}

status_monitoring() {
    if [[ -f $PIDFILE ]]; then
        PID=$(cat $PIDFILE)
        if ps -p $PID > /dev/null; then
            echo "Мониторинг запущен. PID: $PID"
        else
            echo "Мониторинг остановлен, но PID файл существует."
        fi
    else
        echo "Мониторинг не запущен."
    fi
}

stop_monitoring() {
    if [[ -f $PIDFILE ]]; then
        PID=$(cat $PIDFILE)
        kill $PID
        rm -f $PIDFILE
        echo "Мониторинг остановлен."
    else
        echo "Мониторинг не запущен."
    fi
}

# Основная логика
case "$1" in
    START)
        start_monitoring
        ;;
    STATUS)
        status_monitoring
        ;;
    STOP)
        stop_monitoring
        ;;
    *)
        echo "Использование: $0 {START|STOP|STATUS}"
        exit 1
esac
