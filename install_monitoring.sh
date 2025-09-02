#!/bin/bash

# Установка системы мониторинга процесса test
# Installation of test process monitoring system
echo "Установка системы мониторинга..."
echo "Installing monitoring system..."

# Создание скрипта мониторинга с двойными комментариями
# Creation of monitoring script with double comments
sudo tee /usr/local/bin/monitoring.sh > /dev/null << 'EOF'
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
EOF

# Установка прав на выполнение скрипта
# Setting execution permissions for script
sudo chmod +x /usr/local/bin/monitoring.sh

# Создание systemd сервиса
# Creation of systemd service
sudo tee /etc/systemd/system/monitoring.service > /dev/null << 'EOF'
[Unit]
Description=Process Monitoring Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/monitoring.sh
User=root
Group=root

# Настройки безопасности
# Security settings
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=read-only
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

# Создание systemd таймера
# Creation of systemd timer
sudo tee /etc/systemd/system/monitoring.timer > /dev/null << 'EOF'
[Unit]
Description=Timer for process monitoring
Requires=monitoring.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

# Создание лог файла
# Creation of log file
sudo touch /var/log/monitoring.log
sudo chmod 644 /var/log/monitoring.log

# Настройка ротации логов
# Configuration of log rotation
sudo tee /etc/logrotate.d/monitoring > /dev/null << 'EOF'
/var/log/monitoring.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Перезагрузка systemd
# Reload of systemd
sudo systemctl daemon-reload

# Включение и запуск таймера
# Enabling and starting timer
sudo systemctl enable monitoring.timer
sudo systemctl start monitoring.timer

# Завершение установки
# Completion of installation
echo "Установка завершена!"
echo "Installation completed!"

echo "Проверка статуса через команду: systemctl status monitoring.timer"