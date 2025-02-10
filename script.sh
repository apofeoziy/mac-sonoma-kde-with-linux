#!/bin/bash
# Этот скрипт выполняет следующие действия:
# 1. Обновляет систему и устанавливает базовые зависимости (git, kvantummanager и т.д.)
# 2. Если KDE Plasma не установлен, устанавливает его (опционально)
# 3. Клонирует репозиторий MacSonoma-kde и запускает его установочный скрипт
# 4. Устанавливает через AUR дополнительные пакеты (WhiteSur icon theme и WhiteSur cursor theme)
#
# Скрипт рассчитан на работу на уже установленной системе Arch Linux с root‑правами.
# Перед запуском убедитесь, что вы сделали резервное копирование важных данных.

# Проверяем, что скрипт запущен от имени root
if [[ $EUID -ne 0 ]]; then
  echo "Скрипт должен запускаться от имени root" 
  exit 1
fi

# Обновляем систему
echo "Обновление системы..."
pacman -Syu --noconfirm

# Устанавливаем необходимые пакеты
echo "Установка зависимостей: git, kvantummanager, wget, curl и base-devel..."
pacman -S --noconfirm git kvantummanager wget curl base-devel

# (Опционально) Если KDE Plasma не установлен – устанавливаем базовую среду KDE Plasma
if ! pacman -Qs plasma-desktop > /dev/null; then
  echo "KDE Plasma не найден. Устанавливаем KDE Plasma..."
  pacman -S --noconfirm plasma-desktop kde-applications
fi

# Клонируем репозиторий MacSonoma-kde в /tmp
REPO_DIR="/tmp/MacSonoma-kde"
if [ -d "$REPO_DIR" ]; then
  echo "Удаляем существующую директорию $REPO_DIR..."
  rm -rf "$REPO_DIR"
fi
echo "Клонирование репозитория MacSonoma-kde..."
git clone https://github.com/vinceliuice/MacSonoma-kde.git "$REPO_DIR"

# Переходим в директорию репозитория и запускаем установочный скрипт
cd "$REPO_DIR" || exit 1
echo "Запуск установочного скрипта MacSonoma-kde..."
chmod +x install.sh
# Опция --round устанавливает вариант с округлыми элементами (опционально)
./install.sh --round

# Устанавливаем дополнительные рекомендуемые пакеты:
# Проверяем, установлен ли WhiteSur icon theme, если нет – пытаемся установить через yay (из AUR)
if ! pacman -Qs whitesur-icon-theme > /dev/null; then
  echo "WhiteSur icon theme не найден. Попытка установки через AUR..."
  if ! command -v yay &> /dev/null; then
    echo "yay не найден. Устанавливаем yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit 1
    makepkg -si --noconfirm
    cd "$REPO_DIR" || exit 1
  fi
  yay -S --noconfirm whitesur-icon-theme
fi

# Аналогично проверяем и устанавливаем WhiteSur cursor theme
if ! pacman -Qs whitesur-cursor-theme > /dev/null; then
  echo "WhiteSur cursor theme не найден. Устанавливаем через yay..."
  yay -S --noconfirm whitesur-cursor-theme
fi

echo "Установка MacSonoma-kde завершена!"
echo "Перезагрузите систему или выйдите из сессии, чтобы изменения вступили в силу."
