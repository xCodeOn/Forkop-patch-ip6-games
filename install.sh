#!/bin/sh
# Горячий патч установленного Forkop файлами из релиза этого репозитория:
# backend-скрипты и собранный веб-интерфейс ложатся поверх установленных, сервис
# перезагружает конфигурацию. Исходники и сборка не нужны.
#
# Запуск на роутере:
#   wget -O /tmp/hotpatch-install.sh https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install.sh
#   sh /tmp/hotpatch-install.sh [--force]
#
# --force ставит патч-пак, собранный для другой версии Forkop.
set -u

REPO="https://github.com/xCodeOn/Forkop-patch-ip6-games"
WORK=/tmp/forkop-hotpatch
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

say() { echo "hotpatch: $*"; }
die() { say "ОШИБКА: $*"; exit 1; }

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

INSTALLED=$(sed -n 's/.*FORKOP_VERSION: "\([^"]*\)".*/\1/p' /usr/lib/forkop/core/constants.uc 2>/dev/null)
[ -n "$INSTALLED" ] || die "не удалось определить версию установленного Forkop"
say "Установлен Forkop $INSTALLED"

rm -rf "$WORK"
mkdir -p "$WORK"

say "Скачиваю патч-пак из последнего релиза..."
fetch "$REPO/releases/latest/download/hotpatch.tar.gz" "$WORK/hotpatch.tar.gz" ||
    die "не скачал hotpatch.tar.gz — проверьте интернет на роутере"

tar -xzf "$WORK/hotpatch.tar.gz" -C "$WORK" hotpatch.json ||
    die "битый архив: нет манифеста"
BASE=$(sed -n 's/.*"base": *"\([^"]*\)".*/\1/p' "$WORK/hotpatch.json")
[ -n "$BASE" ] || die "битый манифест"

if [ "$BASE" != "$INSTALLED" ] && [ "$FORCE" != 1 ]; then
    die "патч-пак собран для Forkop $BASE, а установлено $INSTALLED. Обновите Forkop до $BASE или запустите с --force"
fi

say "Распаковываю файлы Forkop $BASE..."
tar -xzf "$WORK/hotpatch.tar.gz" -C "$WORK" || die "битый архив"

if command -v sha256sum >/dev/null 2>&1; then
    say "Проверяю контрольные суммы..."
    ( cd "$WORK/files" && sha256sum -c SHA256SUMS >/dev/null 2>&1 ) ||
        die "контрольные суммы файлов не сошлись — архив повреждён"
else
    say "sha256sum в системе нет — пропускаю проверку сумм"
fi

say "Укладываю файлы в систему..."
cp -a "$WORK/files/." / || die "не удалось скопировать файлы"

say "Перезагружаю конфигурацию Forkop..."
/etc/init.d/forkop reload || die "перезагрузка не прошла, смотрите logread | grep forkop"

rm -rf "$WORK"
say "Готово: Forkop $INSTALLED пропатчен. Галочка — в Настройки → Сеть → «Весь трафик через секцию»."
