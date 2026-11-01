<div align="center">

# Forkop patch: ip6 & games

**Два патча поверх [Forkop](https://github.com/ushan0v/forkop) и установка одной командой.**

> **Патчи собраны под версию Forkop 2.0.0.** Вышел новый релиз — запустите workflow
> «Build hot-patch» с его тегом, и пак пересоберётся автоматически.

Весь трафик роутера через VPN одной галочкой и честный DNS без IPv6 — чтобы игровые
клиенты и другие приложения, которые стучатся по IPv6 первыми, больше не зависали
на адресах, до которых нет хода.

[![Build hot-patch](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/hotpatch.yml/badge.svg)](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/hotpatch.yml)
[![Релиз](https://img.shields.io/github/v/release/xCodeOn/Forkop-patch-ip6-games?label=патч&color=0d9488)](../../releases/latest)
[![Лицензия](https://img.shields.io/badge/лицензия-GPL--2.0--or--later-blue)](LICENSE)

<a href="https://pay.cloudtips.ru/p/22326183"><img alt="Поддержать проект" src="https://img.shields.io/badge/%E2%9D%A4%EF%B8%8F_%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%B0%D1%82%D1%8C%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82-CloudTips-8b5cf6?style=for-the-badge"></a>

</div>

---

## Патчи

| Файл | Что делает |
| --- | --- |
| `0001-add-all-traffic-through-section-mode.patch` | **«Весь трафик через секцию»** — галочка в Настройки → Сеть. Выбираете секцию с подключением: все устройства LAN, сам роутер и DNS-запросы идут через неё. Секции Block и Bypass работают как исключения, устройства из «Исключить устройства из маршрутизации» остаются без VPN. Выключается тем же переключателем |
| `0002-suppress-aaaa-without-global-ipv6.patch` | **Честный DNS без IPv6** — если у роутера нет глобального IPv6-адреса, DNS отвечает на AAAA-запросы пустым ответом. Клиенты сразу идут по IPv4: приложения, которые стучатся по IPv6 первыми, — игровые клиенты по UDP среди них, — больше не зависают. Когда провайдер выдаст настоящий IPv6, всё вернётся само |

Патчи независимы: применяйте оба, любой один или ни одного.

### Отдельно для Forkop 1.0.5

Для старой архитектуры 1.0.x есть свой патч —
`forkop-1-0-5-route-all-and-aaaa.patch`: тот же «весь трафик через секцию»
(галочка в Настройки) и те же пустые ответы AAAA без глобального IPv6.
Накладывается на тег `1.0.5`:

```sh
git clone https://github.com/ushan0v/forkop -b 1.0.5 && cd forkop
patch -p1 --fuzz=10 < ../forkop-1-0-5-route-all-and-aaaa.patch
(cd fe-app-forkop && yarn install --frozen-lockfile && yarn build)
./build.sh 1.0.5 out
```

`install.sh` из этого репозитория для 1.0.5 не предназначен — он ставит файлы
архитектуры 2.x. Для 1.0.5 пакеты собираются из пропатченных исходников.

## Установка на роутер одной командой

Патч ставится поверх уже установленного Forkop — исходники и сборка не нужны.
Одна команда в SSH-терминале роутера: скачает скрипт, скачает hot-patch-пак из
релиза, проверит контрольные суммы, уложит файлы и перезагрузит конфигурацию —
без промежуточных шагов.

**Для Forkop 2.0.0:**

```sh
wget -qO - https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install.sh | sh
```

**Для Forkop 1.0.5:**

```sh
wget -qO - https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install-1.0.5.sh | sh
```

Дальше — **Службы → Forkop → Настройки**: в 2.x галочка в группе «Сеть», в 1.0.5 —
«All traffic through section» на странице настроек.

Нюансы:

- скрипты не проверяют версию — каждый ставит свой пак: `install.sh` собран под
  **Forkop 2.0.0**, `install-1.0.5.sh` — под **1.0.5**; для сильно других версий
  пересоберите паки workflow'ом под нужный тег;
- хот-патч слетает при штатном обновлении Forkop — после него просто запустите
  скрипт ещё раз: workflow пересобирает паки под новый тег автоматически;
- ядро [sing-box-forkop](https://github.com/ushan0v/sing-box-forkop) не трогается —
  ставится отдельно, как у официального Forkop;
- конфиг `/etc/config/forkop` сохраняется;
- в 1.0.5 переводы новых строк уже внутри пака (forkop.ru.lmo).

Нюансы:

- версию Forkop скрипт не проверяет — ставится автоматически поверх любой;
  пак в релизе собран под **2.0.0**, для сильно другой версии лучше пересобрать его
  workflow'ом под нужный тег;
- хот-патч слетает при штатном обновлении Forkop — после него просто запустите скрипт
  ещё раз: workflow пересобирает пак под новый тег автоматически;
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

<a href="https://pay.cloudtips.ru/p/22326183"><img alt="Поддержать проект" src="https://img.shields.io/badge/%E2%9D%A4%EF%B8%8F_%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%B0%D1%82%D1%8C%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82-CloudTips-8b5cf6?style=for-the-badge"></a>

</div>

База — проект [Forkop](https://github.com/ushan0v/forkop) от [ushan0v](https://github.com/ushan0v).

## Лицензия

Как и Forkop — [GPL-2.0-or-later](LICENSE).
