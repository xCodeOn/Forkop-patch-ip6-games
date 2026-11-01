<div align="center">

# Forkop patch: ip6

**Патч для [Forkop 2.x](https://github.com/ushan0v/forkop)
и установка одной командой.**

Честный DNS без IPv6 — чтобы игровые клиенты и другие приложения, которые стучатся
по IPv6 первыми, больше не зависали на адресах, до которых нет хода.

[![Build hot-patch](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/hotpatch.yml/badge.svg)](https://github.com/xCodeOn/Forkop-patch-ip6-games/actions/workflows/hotpatch.yml)
[![Релиз](https://img.shields.io/github/v/release/xCodeOn/Forkop-patch-ip6-games?label=патч&color=0d9488)](../../releases/latest)
[![Лицензия](https://img.shields.io/badge/лицензия-GPL--2.0--or--later-blue)](LICENSE)

<a href="https://pay.cloudtips.ru/p/22326183"><img alt="Поддержать проект" src="https://img.shields.io/badge/%E2%9D%A4%EF%B8%8F_%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%B0%D1%82%D1%8C%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82-CloudTips-8b5cf6?style=for-the-badge"></a>

</div>

---

## Что делает патч

| Файл | Что делает |
| --- | --- |
| `patch-fix-game-suppress-aaaa-without-global-ipv6.patch` | **Честный DNS без IPv6** — если у роутера нет глобального IPv6-адреса, DNS отвечает на AAAA-запросы пустым ответом. Клиенты сразу идут по IPv4: приложения, которые стучатся по IPv6 первыми, — игровые клиенты по UDP среди них, — больше не зависают. Когда провайдер выдаст настоящий IPv6, всё вернётся само |

## Установка на роутер одной командой

Патч ставится поверх уже установленного Forkop 2.x — исходники и сборка не нужны.
Одна команда в SSH-терминале роутера: скачает скрипт и hot-patch-пак из релиза,
проверит контрольные суммы, уложит файлы и перезагрузит конфигурацию — без
промежуточных шагов:

```sh
wget -qO - https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/install.sh | sh
```

Дальше — **Службы → Forkop → Статус → Запустить диагностику**: проверка «DNS» теперь
должна проходить без зависаний, а устройства за роутером сразу обращаются по IPv4.

Нюансы:

- скрипт версию не проверяет и ставит файлы поверх любой; пак в релизе собран под
  свежий 2.x — для сильно другой версии пересоберите его workflow'ом под нужный тег;
- хот-патч слетает при штатном обновлении Forkop — после него просто запустите
  команду ещё раз: workflow пересобирает пак под новый тег автоматически;
- ядро [sing-box-forkop](https://github.com/ushan0v/sing-box-forkop) не трогается —
  ставится отдельно, как у официального Forkop;
- конфиг `/etc/config/forkop` сохраняется.

## Как применить патч к исходникам

Если нужны полноценные пакеты или хотите носить патч в своей сборке — наложите его
на свежие исходники Forkop (ветка `main`) и соберите штатным сборщиком:

```sh
git clone https://github.com/ushan0v/forkop && cd forkop

patch -p1 --fuzz=10 < ../patch-fix-game-suppress-aaaa-without-global-ipv6.patch

(cd fe-app-forkop && yarn install --frozen-lockfile && yarn locales && yarn build)
./build.sh 2.0.1 out        # в out/ появятся *_all.ipk и *_all.apk
```

Свежий патч — в [релизах](../../releases/latest), либо прямой ссылкой:

```sh
curl -LO https://github.com/xCodeOn/Forkop-patch-ip6-games/releases/latest/download/patch-fix-game-suppress-aaaa-without-global-ipv6.patch
```

`git apply` строже — если он отказался, `patch -p1 --fuzz=10` добьёт.

Workflow **Build hot-patch** делает то же самое на CI: накладывает патч на выбранный
тег или ветку upstream, пересобирает веб-интерфейс, прогоняет тесты и публикует
готовый hot-patch-пак в релиз. Свежий патч собран из `main` — запустите workflow со
`source_ref=main` и версией пакета, чтобы собрать под актуальный upstream.

## Поддержать

Патч бесплатен и делается в свободное время. Если он полезен, лучшее спасибо — звезда и донат:

<div align="center">

<a href="https://pay.cloudtips.ru/p/22326183"><img alt="Поддержать проект" src="https://img.shields.io/badge/%E2%9D%A4%EF%B8%8F_%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%B0%D1%82%D1%8C%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82-CloudTips-8b5cf6?style=for-the-badge"></a>

</div>

База — проект [Forkop](https://github.com/ushan0v/forkop) от [ushan0v](https://github.com/ushan0v).

## Лицензия

Как и Forkop — [GPL-2.0-or-later](LICENSE).
