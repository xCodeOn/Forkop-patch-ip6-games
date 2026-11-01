#!/bin/sh
# Горячий патч установленного Forkop файлами из релиза этого репозитория:
# backend-скрипты и собранный веб-интерфейс ложатся поверх установленных, сервис
# перезагружает конфигурацию. Исходники и сборка не нужны. Версию не проверяет,
# ставится автоматически поверх любой.
#
# Запуск на роутере:
#   wget -O /tmp/hotpatch-install.sh https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install.sh
#   sh /tmp/hotpatch-install.sh
set -u

REPO="https://github.com/xCodeOn/Forkop-patch-ip6-games"
WORK=/tmp/forkop-hotpatch

die() { echo "hotpatch: ОШИБКА: $*"; exit 1; }

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

rm -rf "$WORK"
mkdir -p "$WORK"

fetch "$REPO/releases/latest/download/hotpatch.tar.gz" "$WORK/hotpatch.tar.gz" ||
    die "не скачал hotpatch.tar.gz — проверьте интернет на роутере"

tar -xzf "$WORK/hotpatch.tar.gz" -C "$WORK" || die "битый архив"

if command -v sha256sum >/dev/null 2>&1; then
    ( cd "$WORK/files" && sha256sum -c ../SHA256SUMS >/dev/null 2>&1 ) ||
        die "контрольные суммы файлов не сошлись — архив повреждён"
fi

cp -a "$WORK/files/." / || die "не удалось скопировать файлы"

/etc/init.d/forkop reload || die "перезагрузка не прошла, смотрите logread | grep forkop"

rm -rf "$WORK"
echo "hotpatch: Готово. Галочка — в Настройки → Сеть → «Весь трафик через секцию»."
