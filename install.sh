#!/bin/sh
# Горячий патч установленного Forkop файлами из релиза этого репозитория:
# backend-скрипты и собранный веб-интерфейс ложатся поверх установленных, сервис
# перезагружает конфигурацию. Исходники и сборка не нужны.
# Патч: пустые ответы AAAA без глобального IPv6.
#
# Версию Forkop скрипт не проверяет — ставится автоматически поверх любой.
#
# Запуск на роутере:
#   wget -O /tmp/hotpatch-install.sh https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install.sh
#   sh /tmp/hotpatch-install.sh
set -u

REPO="https://github.com/xCodeOn/Forkop-patch-ip6-games"
WORK=/tmp/forkop-hotpatch

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
[ -f /usr/lib/forkop/singbox/generator.uc ] ||
    die "установлен Forkop 1.x — патчи собраны под 2.x. Сначала обновите Forkop до 2.x официальным установщиком (ushan0v/forkop), затем вернитесь к hot-patch"

INSTALLED=$(sed -n 's/.*FORKOP_VERSION: "\([^"]*\)".*/\1/p' /usr/lib/forkop/core/constants.uc 2>/dev/null)
say "Установлен Forkop ${INSTALLED:-неизвестной версии}"

rm -rf "$WORK"
mkdir -p "$WORK"

say "Скачиваю патч-пак из последнего релиза..."
fetch "$REPO/releases/latest/download/hotpatch.tar.gz" "$WORK/hotpatch.tar.gz" ||
    die "не скачал hotpatch.tar.gz — проверьте интернет на роутере"

say "Распаковываю файлы..."
tar -xzf "$WORK/hotpatch.tar.gz" -C "$WORK" || die "битый архив"

if command -v sha256sum >/dev/null 2>&1; then
    say "Проверяю контрольные суммы..."
    ( cd "$WORK/files" && sha256sum -c ../SHA256SUMS >/dev/null 2>&1 ) ||
        die "контрольные суммы файлов не сошлись — архив повреждён"
else
    say "sha256sum в системе нет — пропускаю проверку сумм"
fi

say "Укладываю файлы в систему..."
cp -a "$WORK/files/." / || die "не удалось скопировать файлы"

say "Перезагружаю конфигурацию Forkop..."
/etc/init.d/forkop reload || die "перезагрузка не прошла, смотрите logread | grep forkop"

rm -rf "$WORK"
say "Готово: Forkop $INSTALLED пропатчен. Пустые ответы AAAA работают без глобального IPv6."
