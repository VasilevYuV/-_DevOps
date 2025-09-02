#!/bin/bash

# Удаление системы мониторинга процесса test
# Removal of test process monitoring system
echo "Удаление системы мониторинга..."
echo "Removing monitoring system..."

# Остановка и отключение сервисов
# Stopping and disabling services
sudo systemctl stop monitoring.timer
sudo systemctl disable monitoring.timer
sudo systemctl daemon-reload

# Удаление файлов конфигурации
# Removal of configuration files
sudo rm -f /usr/local/bin/monitoring.sh
sudo rm -f /etc/systemd/system/monitoring.service
sudo rm -f /etc/systemd/system/monitoring.timer
sudo rm -f /etc/logrotate.d/monitoring
sudo rm -f /var/run/monitoring.pid

# Сохранение лог файла (возможность ручного удаления)
# Preservation of log file (possibility of manual removal)
echo "Лог файл сохранен: /var/log/monitoring.log"
echo "Log file preserved: /var/log/monitoring.log"
echo "Для полного удаления выполните: sudo rm /var/log/monitoring.log"
echo "For complete removal execute: sudo rm /var/log/monitoring.log"

# Завершение удаления
# Completion of removal
echo "Удаление завершено!"
echo "Removal completed!"