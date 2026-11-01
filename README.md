<div align="center">

# Forkop patch: ip6 & games

**Патчи для [Forkop](https://github.com/ushan0v/forkop), которые собираются в готовые пакеты одной кнопкой.**

Весь трафик роутера через VPN одной галочкой и честный DNS без IPv6 — чтобы игровые
клиенты и другие приложения, которые стучатся по IPv6 первыми, больше не зависали
на адресах, до которых нет хода.

[![Build patched packages](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/patched-build.yml/badge.svg)](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/patched-build.yml)
[![Релизы](https://img.shields.io/github/v/release/xCodeOn/Forkop-patch-ip6-games?label=релиз&color=0d9488)](../../releases)
[![Лицензия](https://img.shields.io/badge/лицензия-GPL--2.0--or--later-blue)](LICENSE)

</div>

---

## Что внутри

### 0001 — «Весь трафик через секцию»

Одна галочка в **Настройки → Сеть → Весь трафик через секцию**. Выбираете секцию с
подключением — и весь трафик, который не забрали секции выше, идёт через неё:

- все устройства LAN и **сам роутер**;
- **DNS-запросы автоматически** идут через ту же секцию — провайдер не видит домены;
- секции Block и Bypass работают как раньше — это ваши исключения;
- устройства из «Исключить устройства из маршрутизации» остаются без VPN.

Никаких ручных правил «на каждый сайт»: одна галочка — и роутер стал VPN-шлюзом.
Выключается тем же переключателем, конфиг при этом не трогается.

### 0002 — честный DNS без IPv6

Если у роутера нет глобального IPv6-адреса (провайдер даёт только IPv4), любой AAAA-ответ
указывает на адрес, до которого **нет хода**. Приложения, которые стучатся по IPv6
первыми, — игровые клиенты по UDP среди них — на таких адресах просто зависают.

Патч делает DNS честным: пока глобального IPv6 нет, Forkop отвечает на AAAA-запросы
пустым ответом, и клиенты сразу идут по IPv4. Как только провайдер выдаст настоящий
IPv6 — всё вернётся автоматически, без настроек.

Патчи независимы: можно собрать оба, любой один или ни одного.

## Сборка

Всё собирается этим же репозиторием: **Actions → Build patched packages → Run workflow**.

| Параметр | Что задаёт |
| --- | --- |
| `source_repo` | чей исходный код патчим, по умолчанию `ushan0v/forkop` |
| `source_ref` | тег или ветка, например `v2.0.1`; пусто — последний релиз upstream |
| `package_version` | версия пакетов `x.y.z`; пусто — номер тега |
| `apply_route_all` / `apply_aaaa` | какие патчи накладывать |
| `run_tests` | прогнать ucode-тесты после патчей |

Готовый прогон кладёт в релиз `v<версия>` все пакеты: `forkop`, `luci-app-forkop`,
`luci-i18n-forkop-ru` — сразу в **ipk** (OpenWrt 24.10) и **apk** (OpenWrt 25.12+),
плюс `install.sh`, `release.json` и `SHA256SUMS`.

Когда выйдет новая версия Forkop — просто запустите workflow с её тегом: патчи
наложатся на свежие исходники, тесты прогонятся, релиз обновится.

## Установка на роутер

Скачайте релиз и выполните по SSH:

**OpenWrt 25.12 и новее (apk):**

```sh
scp forkop_*_all.apk luci-app-forkop_*_all.apk luci-i18n-forkop-ru_*_all.apk root@192.168.8.8:/tmp/
ssh root@192.168.8.8 'apk add --allow-untrusted --no-network --repositories-file /dev/null /tmp/forkop_*_all.apk /tmp/luci-app-forkop_*_all.apk /tmp/luci-i18n-forkop-ru_*_all.apk'
```

**OpenWrt 24.10 (opkg):**

```sh
ssh root@192.168.8.8 'opkg install /tmp/forkop_*_all.ipk /tmp/luci-app-forkop_*_all.ipk /tmp/luci-i18n-forkop-ru_*_all.ipk'
```

Требования — как у официального Forkop: OpenWrt 24.10+, от 128 МБ ОЗУ, установленное
ядро [sing-box-forkop](https://github.com/ushan0v/sing-box-forkop) нужной версии.
Конфиг `/etc/config/forkop` при обновлении сохраняется.

После установки: **Службы → Forkop → Настройки → Сеть → Весь трафик через секцию**.

## Документация

- Подробности патч-комплекта — [patchip6/README.md](patchip6/README.md)
- Официальная документация Forkop — [ushan0v.github.io/forkop](https://ushan0v.github.io/forkop/)
- Вопросы по базе Forkop — [чат в Telegram](https://t.me/forkop_chat)

## Поддержать

Сам проект **Forkop** делает [ushan0v](https://github.com/ushan0v) — патчи здесь лишь
надстройка. Поблагодарить автора базы можно так:

* 💳 **Карты РФ / СБП / Tinkoff Pay:** [Донат на CloudTips](https://pay.cloudtips.ru/p/385e5af2)
* 💎 **USDT (сеть TON):** `UQAOCDav39WJ2gvnzs9RQ_IsF2dcGrcpw4U0j6XGO7je7uwm`
* 🟢 **USDT (сеть TRC-20):** `TEMaZFyM8RQpkbd5LvB8CFJwxCyhHauKAe`
* 🪙 **USDT (ERC-20 / BEP-20 / Polygon / Monad):** `0xe8aabb21c320240fe45b6087e68c6fe40a92d8bf`
* 🟠 **USDT (сеть Solana):** `AhhUjTci9zDKQjUfgLacFR4LiHX9nmZud6DZ8YdbpjEB`

## Лицензия

Как и Forkop — [GPL-2.0-or-later](LICENSE).
