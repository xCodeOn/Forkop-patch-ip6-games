<div align="center">

# Forkop patch: ip6 & games

**Два патча поверх [Forkop](https://github.com/ushan0v/forkop) — забрать их можно прямо отсюда.**

Весь трафик роутера через VPN одной галочкой и честный DNS без IPv6 — чтобы игровые
клиенты и другие приложения, которые стучатся по IPv6 первыми, больше не зависали
на адресах, до которых нет хода.

[![Релиз](https://img.shields.io/github/v/release/xCodeOn/Forkop-patch-ip6-games?label=патчи&color=0d9488)](../../releases/latest)
[![Лицензия](https://img.shields.io/badge/лицензия-GPL--2.0--or--later-blue)](LICENSE)

</div>

---

## Патчи

| Файл | Что делает |
| --- | --- |
| `0001-add-all-traffic-through-section-mode.patch` | **«Весь трафик через секцию»** — галочка в Настройки → Сеть. Выбираете секцию с подключением: все устройства LAN, сам роутер и DNS-запросы идут через неё. Секции Block и Bypass работают как исключения, устройства из «Исключить устройства из маршрутизации» остаются без VPN. Выключается тем же переключателем |
| `0002-suppress-aaaa-without-global-ipv6.patch` | **Честный DNS без IPv6** — если у роутера нет глобального IPv6-адреса, DNS отвечает на AAAA-запросы пустым ответом. Клиенты сразу идут по IPv4: приложения, которые стучатся по IPv6 первыми, — игровые клиенты по UDP среди них, — больше не зависают. Когда провайдер выдаст настоящий IPv6, всё вернётся само |

Патчи независимы: применяйте оба, любой один или ни одного.

## Как применить

Патчи кладутся на исходники Forkop нужной версии. Свежие — в
[релизах](../../releases/latest), либо прямой ссылкой:

```sh
curl -LO https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/0001-add-all-traffic-through-section-mode.patch
curl -LO https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/0002-suppress-aaaa-without-global-ipv6.patch
```

Наложить на исходники и собрать пакеты штатным сборщиком Forkop:

```sh
git clone https://github.com/ushan0v/forkop -b 2.0.0 && cd forkop

patch -p1 --fuzz=10 < ../0001-add-all-traffic-through-section-mode.patch
patch -p1 --fuzz=10 < ../0002-suppress-aaaa-without-global-ipv6.patch

(cd fe-app-forkop && yarn install --frozen-lockfile && yarn locales && yarn build)
./build.sh 2.0.0 out        # в out/ появятся *_all.ipk и *_all.apk
```

Вместо `2.0.0` берите тег версии, на которую накладываете: патчи пишутся с запасом
контекста и ложатся на соседние версии через `--fuzz`. `git apply` строже — если он
отказался, `patch -p1 --fuzz=10` добьёт.

После установки пакетов: **Службы → Forkop → Настройки → Сеть → Весь трафик через секцию**.

Требования — как у официального Forkop: OpenWrt 24.10+, от 128 МБ ОЗУ, ядро
[sing-box-forkop](https://github.com/ushan0v/sing-box-forkop). Конфиг
`/etc/config/forkop` при обновлении сохраняется.

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
