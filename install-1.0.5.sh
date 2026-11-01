#!/bin/sh
# Горячий патч для Forkop 1.0.x файлами из релиза этого репозитория:
# backend-скрипты, веб-интерфейс и переводы ложатся поверх установленных, сервис
# перезагружает конфигурацию. Исходники и сборка не нужны. Версию не проверяет
# сверх принадлежности к 1.0.x — ставится автоматически.
#
# Запуск на роутере:
#   wget -qO - https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install-1.0.5.sh | sh
set -u

REPO="https://github.com/xCodeOn/Forkop-patch-ip6-games"
WORK=/tmp/forkop-hotpatch-105

die() { echo "hotpatch-1.0.5: ОШИБКА: $*"; exit 1; }

fetch() { # fetch URL FILE
    wget -T 30 -q -O "$2" "$1" 2>/dev/null && [ -s "$2" ] && return 0
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2" 2>/dev/null && [ -s "$2" ] && return 0
    fi
    return 1
}

[ "$(id -u)" = "0" ] || die "запускайте под root"
[ -x /usr/bin/forkop ] || die "Forkop не установлен (/usr/bin/forkop не найден)"
[ -x /etc/init.d/forkop ] || die "сервис forkop не найден"

CONFIG_VERSION=$(uci -q get forkop.settings.config_version 2>/dev/null)
case "$CONFIG_VERSION" in
    1.*) echo "hotpatch-1.0.5: Forkop 1.0.x (конфиг $CONFIG_VERSION) — подходит" ;;
    *) die "это скрипт для Forkop 1.0.x, а версия конфига ${CONFIG_VERSION:-неизвестна}. Для Forkop 2.x используйте install.sh" ;;
esac
[ -f /www/luci-static/resources/view/forkop/settings.js ] ||
    die "не найден settings.js — структура установки не соответствует 1.0.x"

rm -rf "$WORK"
mkdir -p "$WORK"

fetch "$REPO/releases/latest/download/hotpatch-1.0.5.tar.gz" "$WORK/hotpatch.tar.gz" ||
    die "не скачал hotpatch-1.0.5.tar.gz — проверьте интернет на роутере"

tar -xzf "$WORK/hotpatch.tar.gz" -C "$WORK" || die "битый архив"

if command -v sha256sum >/dev/null 2>&1; then
    ( cd "$WORK/files" && sha256sum -c ../SHA256SUMS >/dev/null 2>&1 ) ||
        die "контрольные суммы файлов не сошлись — архив повреждён"
fi

cp -a "$WORK/files/." / || die "не удалось скопировать файлы"

/etc/init.d/forkop reload || die "перезагрузка не прошла, смотрите logread | grep forkop"

rm -rf "$WORK"
echo "hotpatch-1.0.5: Готово. Галочка — в Настройки → «All traffic through section»."
