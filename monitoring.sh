#!/bin/bash

# Скрипт мониторинга процесса test
# Process test monitoring script
LOG_FILE="/var/log/monitoring.log"
PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"
PID_FILE="/var/run/monitoring.pid"

# Функция для логирования
# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Проверка запущенного процесса
# Check of running process
check_process() {
    if pgrep -x "$PROCESS_NAME" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Проверка состояния сервера мониторинга
# Check of monitoring server status
check_monitoring_server() {
    if curl -s -f --connect-timeout 10 --max-time 15 "$MONITORING_URL" > /dev/null; then
        return 0
    else
        log_message "ERROR: Мониторинг сервер $MONITORING_URL недоступен"
        return 1
    fi
}

# Основная логика
# Main logic
main() {
    # Проверка запущенного процесса
    # Check of running process
    if check_process; then
        CURRENT_PID=$(pgrep -x "$PROCESS_NAME")
        
        # Проверка перезапуска процесса
        # Check of process restart
        if [ -f "$PID_FILE" ]; then
            OLD_PID=$(cat "$PID_FILE")
            if [ "$CURRENT_PID" != "$OLD_PID" ]; then
                log_message "INFO: Процесс $PROCESS_NAME был перезапущен (старый PID: $OLD_PID, новый PID: $CURRENT_PID)"
            fi
        fi
        
        # Сохранение текущего PID
        # Saving current PID
        echo "$CURRENT_PID" > "$PID_FILE"
        
        # Проверка сервера мониторинга
        # Check of monitoring server
        if check_monitoring_server; then
            # Отправка heartbeat (возможность добавления дополнительных данных)
            # Sending heartbeat (ability to add additional data)
            curl -s -f --connect-timeout 10 --max-time 15 \
                 -H "Content-Type: application/json" \
                 -X POST "$MONITORING_URL" \
                 -d "{\"process\": \"$PROCESS_NAME\", \"pid\": $CURRENT_PID, \"status\": \"running\"}" \
                 > /dev/null 2>&1
        fi
    else
        # Удаление PID файла при отсутствии процесса
        # Removal of PID file when process is not running
        if [ -f "$PID_FILE" ]; then
            rm -f "$PID_FILE"
        fi
    fi
}

# Запуск основной функции
# Launch of main function
main "$@"