<div align="center">

# Forkop patch: ip6 & games

**Два патча поверх [Forkop](https://github.com/ushan0v/forkop) и установка одной командой.**

Весь трафик роутера через VPN одной галочкой и честный DNS без IPv6 — чтобы игровые
клиенты и другие приложения, которые стучатся по IPv6 первыми, больше не зависали
на адресах, до которых нет хода.

[![Build hot-patch](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/hotpatch.yml/badge.svg)](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/hotpatch.yml)
[![Релиз](https://img.shields.io/github/v/release/xCodeOn/Forkop-patch-ip6-games?label=патч&color=0d9488)](../../releases/latest)
[![Лицензия](https://img.shields.io/badge/лицензия-GPL--2.0--or--later-blue)](LICENSE)

</div>

---

## Патчи

| Файл | Что делает |
| --- | --- |
| `0001-add-all-traffic-through-section-mode.patch` | **«Весь трафик через секцию»** — галочка в Настройки → Сеть. Выбираете секцию с подключением: все устройства LAN, сам роутер и DNS-запросы идут через неё. Секции Block и Bypass работают как исключения, устройства из «Исключить устройства из маршрутизации» остаются без VPN. Выключается тем же переключателем |
| `0002-suppress-aaaa-without-global-ipv6.patch` | **Честный DNS без IPv6** — если у роутера нет глобального IPv6-адреса, DNS отвечает на AAAA-запросы пустым ответом. Клиенты сразу идут по IPv4: приложения, которые стучатся по IPv6 первыми, — игровые клиенты по UDP среди них, — больше не зависают. Когда провайдер выдаст настоящий IPv6, всё вернётся само |

Патчи независимы: применяйте оба, любой один или ни одного.

## Установка на роутер одной командой

Патч ставится поверх уже установленного Forkop — исходники и сборка не нужны.
Подключитесь к роутеру по SSH и выполните:

```sh
wget -O /tmp/hotpatch-install.sh https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install.sh
sh /tmp/hotpatch-install.sh
```

Скрипт скачает hot-patch-пак из релиза, проверит контрольные суммы, уложит файлы
и перезагрузит конфигурацию Forkop. Дальше — **Службы → Forkop → Настройки → Сеть →
Весь трафик через секцию**.

Нюансы:

- скрипт сверяет версию: пак собран под конкретную версию Forkop, для другой нужен
  `sh /tmp/hotpatch-install.sh --force`;
- хот-патч слетает при штатном обновлении Forkop — после него просто запустите скрипт
  ещё раз: workflow ниже пересобирает пак под новый тег автоматически;
- ядро [sing-box-forkop](https://github.com/ushan0v/sing-box-forkop) не трогается —
  ставится отдельно, как у официального Forkop;
- конфиг `/etc/config/forkop` сохраняется.

## Как применить патчи к исходникам

Если нужны полноценные пакеты или хотите носить патчи в своей сборке — наложите их
на исходники Forkop нужной версии и соберите штатным сборщиком:

```sh
git clone https://github.com/ushan0v/forkop -b 2.0.0 && cd forkop

patch -p1 --fuzz=10 < ../0001-add-all-traffic-through-section-mode.patch
patch -p1 --fuzz=10 < ../0002-suppress-aaaa-without-global-ipv6.patch

(cd fe-app-forkop && yarn install --frozen-lockfile && yarn locales && yarn build)
./build.sh 2.0.0 out        # в out/ появятся *_all.ipk и *_all.apk
```

Свежие патчи — в [релизах](../../releases/latest), либо прямой ссылкой:

```sh
curl -LO https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/0001-add-all-traffic-through-section-mode.patch
curl -LO https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/0002-suppress-aaaa-without-global-ipv6.patch
```

`git apply` строже — если он отказался, `patch -p1 --fuzz=10` добьёт. Порядок: сначала
`0001`, затем `0002`; патчи независимы, можно взять только один.

Workflow **Build hot-patch** делает то же самое на CI: накладывает патчи на выбранный
тег upstream, пересобирает веб-интерфейс, прогоняет тесты и публикует готовый
hot-patch-пак в релиз. Вышла новая версия Forkop — запустите с её тегом.

## Поддержать

Патчи бесплатны и делаются в свободное время. Если они полезны, лучшее спасибо — звезда и донат:

<div align="center">

<a href="https://pay.cloudtips.ru/p/22326183"><img alt="Support the project" src="https://img.shields.io/badge/%E2%9D%A4%EF%B8%8F_Support_the_project-CloudTips-8b5cf6?style=for-the-badge"></a>

</div>

База — проект [Forkop](https://github.com/ushan0v/forkop) от [ushan0v](https://github.com/ushan0v).

## Лицензия

Как и Forkop — [GPL-2.0-or-later](LICENSE).
