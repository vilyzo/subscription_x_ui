#!/bin/bash

# Функция для запроса переменной с возможностью оставить значение по умолчанию
ask_variable() {
  local var_name="$1"
  local default_value="$2"
  local user_input

  read -p "Введите значение для $var_name (по умолчанию: $default_value): " user_input
  echo "${user_input:-$default_value}"
}

# Клонируем репозиторий
echo "Клонирование репозитория..."
git clone https://github.com/vilyzo/subscription_x_ui.git .

# Устанавливаем Docker
echo "Установка Docker..."
sudo apt update
sudo apt install -y docker.io

# Устанавливаем Docker Compose
echo "Установка Docker Compose..."
sudo apt install -y docker-compose

# Запрос переменных с возможностью изменить или оставить по умолчанию
echo "Настройка переменных среды..."

DB_PATCH=$(ask_variable "DB_PATCH" "/app/x-ui.db")
SERVER_ADDRESS=$(ask_variable "SERVER_ADDRESS" "834572350.duckdns.org")
SERVER_PORT=$(ask_variable "SERVER_PORT" "443")
PUBLIC_KEY=$(ask_variable "PUBLIC_KEY" "FNaVxy1hPV40Xtm0OnoxqsxSNuQoLmWILUT6FwsdUmI")
SID=$(ask_variable "SID" "c2&spx=%2F")
SNI=$(ask_variable "SNI" "google.com")
FP=$(ask_variable "FP" "safari")

# Замена переменных в docker-compose.yml
echo "Обновление файла docker-compose.yml..."

cat > docker-compose.yml <<EOF
version: '3.8'
services:
  app:
    build:
      context: .
    container_name: subscription-xray
    ports:
      - "8000:8000"
    volumes:
      - /home/vilyzo/subscription_api/app.log:/app/app.log
      - /etc/x-ui/x-ui.db:/app/x-ui.db
    environment:
      DB_PATCH: "$DB_PATCH"
      SERVER_ADDRESS: "$SERVER_ADDRESS"
      SERVER_PORT: "$SERVER_PORT"
      PUBLIC_KEY: "$PUBLIC_KEY"
      SID: "$SID"
      SNI: "$SNI"
      FP: "$FP"
EOF

# Спрашиваем, нужно ли остановить и очистить контейнеры и образы
CLEANUP=$(ask_variable "Хотите остановить и очистить контейнеры, образы и тома? (yes/no)" "no")

if [[ "$CLEANUP" == "yes" ]]; then
  echo "Остановка контейнеров, очистка системы..."
  sudo docker-compose down
  sudo docker system prune -a --volumes -f
else
  echo "Остановка и очистка контейнеров пропущена."
fi

# Запуск контейнеров с пересборкой
echo "Запуск контейнеров с пересборкой..."
sudo docker-compose up --build -d

echo "Скрипт выполнен!"
