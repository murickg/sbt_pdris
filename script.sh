#!/bin/bash

# Путь к PID файлу
PIDFILE="/tmp/disk_monitor.pid"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Функция для мониторинга дискового пространства и inodes
monitor_disk() {
    while true; do
        FILENAME="disk_usage_$TIMESTAMP.csv"

        df -h | awk 'NR==1 || /^\/dev\//' > "$FILENAME"
        df -ih | awk 'NR==1 || /^\/dev\//' >> "$FILENAME"

        sleep 60

        NEW_DAY=$(date +"%Y-%m-%d")
        if [[ "$NEW_DAY" != "$CURRENT_DAY" ]]; then
            TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        fi
    done
}

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
