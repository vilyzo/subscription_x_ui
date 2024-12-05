#!/bin/bash

# Проверка наличия git и его установка, если отсутствует
if ! command -v git &> /dev/null; then
  echo "Git не установлен. Устанавливаю..."
  sudo apt update
  sudo apt install -y git
else
  echo "Git уже установлен."
fi

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

DB_PATCH=$(ask_variable "DB_PATCH (путь внутри контейнера)" "/app/x-ui.db")
SERVER_ADDRESS=$(ask_variable "SERVER_ADDRESS" "834572350.duckdns.org")
SERVER_PORT=$(ask_variable "SERVER_PORT" "443")
PUBLIC_KEY=$(ask_variable "PUBLIC_KEY" "FNaVxy1hPV40Xtm0OnoxqsxSNuQoLmWILUT6FwsdUmI")
SID=$(ask_variable "SID" "c2&spx=%2F")
SNI=$(ask_variable "SNI" "google.com")
FP=$(ask_variable "FP" "safari")
HOST_DB_PATH=$(ask_variable "HOST_DB_PATH (путь к файлу базы данных на хосте)" "/etc/x-ui/x-ui.db")

# Замена переменных в docker-compose.yml
echo "Обновление файла docker-compose.yml..."

cat > docker-compose.yml <<EOF
services:
  app:
    build:
      context: .
    container_name: subscription-xray
    ports:
      - "8000:8000"
    volumes:
      - ./app.log:/app/app.log
      - $HOST_DB_PATH:$DB_PATCH
    environment:
      DB_PATCH: "$DB_PATCH"
      SERVER_ADDRESS: "$SERVER_ADDRESS"
      SERVER_PORT: "$SERVER_PORT"
      PUBLIC_KEY: "$PUBLIC_KEY"
      SID: "$SID"
      SNI: "$SNI"
      FP: "$FP"
EOF

# Спрашиваем, нужно ли остановить и очистить контейнеры, образы и тома
CLEANUP=$(ask_variable "Хотите остановить и очистить контейнеры, образы и тома данного проекта? (yes/no)" "no")

if [[ "$CLEANUP" == "yes" ]]; then
  echo "Остановка и очистка контейнеров, образов и томов проекта..."

  # Останавливаем и удаляем только связанные с проектом контейнеры
  sudo docker-compose down

  # Удаляем только связанные с проектом образы
  PROJECT_IMAGES=$(docker images --filter "label=com.docker.compose.project=$(basename $PWD)" -q)
  if [[ ! -z "$PROJECT_IMAGES" ]]; then
    sudo docker rmi $PROJECT_IMAGES
  fi

  # Удаляем тома, связанные только с этим проектом
  PROJECT_VOLUMES=$(docker volume ls --filter "label=com.docker.compose.project=$(basename $PWD)" -q)
  if [[ ! -z "$PROJECT_VOLUMES" ]]; then
    sudo docker volume rm $PROJECT_VOLUMES
  fi

else
  echo "Остановка и очистка контейнеров, образов и томов пропущена."
fi

# Запуск контейнеров с пересборкой
echo "Запуск контейнеров с пересборкой..."
sudo docker-compose up --build -d

echo "Скрипт выполнен!"
