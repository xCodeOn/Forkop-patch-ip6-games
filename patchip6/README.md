# Патч-комплект Forkop

Два патча поверх официального Forkop и GitHub Actions workflow, который собирает из
пропатченных исходников пакеты `*_all.ipk` и `*_all.apk`. Порядок обновления: вышел
новый релиз upstream — запускаете workflow с его тегом, скачиваете артефакт, ставите
на роутер. Конфиг `/etc/config/forkop` при обновлении сохраняется.

## Патчи

### 0001 — «Весь трафик через секцию» (`apply_route_all`)

Одна галочка в **Настройки → Сеть**: выбираете секцию — и весь трафик, который не
забрали секции выше, идёт через неё: все устройства LAN, сам роутер и DNS-запросы
(автоматически, без ручного «DNS через секцию»). Секции Block/Bypass продолжают
работать как исключения, устройства из «Исключить устройства из маршрутизации»
остаются без VPN.

- backend: `nft/apply.uc` (перехват), `singbox/generator.uc` (catch-all правило),
  `singbox/dns.uc` (авто-детур DNS), `config/validator.uc`, `diagnostics/checks.uc`,
  дефолтный конфиг;
- фронтенд: переключатель в `settings/form/network.ts` + переводы;
- тесты: `tests/singbox/generator_route_all.test.uc` и кейсы в трёх файлах.

### 0002 — пустые ответы AAAA без глобального IPv6 (`apply_aaaa`)

Если у роутера нет глобального IPv6-адреса (2000::/3), DNS больше не выдаёт AAAA:
fakeip-сервер теряет v6-пул, а первое DNS-правило отвечает пусто на все остальные
AAAA-запросы с LAN. Клиенты сразу идут по IPv4, и приложения, которые стучатся по
IPv6 первыми, — игровые клиенты по UDP среди них — не зависают на адресах, до
которых нет хода. Именно это лечило Heroes of the Storm за таким роутером.

Патчи независимы: можно применять оба, любой один или ни одного.

## Сборка через Actions

1. Закоммитьте этот репозиторий (папка `patchip6/` и `.github/workflows/patched-build.yml`)
   и запушьте в свой GitHub.
2. **Actions → Build patched packages → Run workflow**:
   - `source_repo` — чей исходный код патчим, по умолчанию `ushan0v/forkop`;
   - `source_ref` — тег или ветка, например `v2.0.1`; пусто = последний релиз upstream;
   - `package_version` — версия пакетов `x.y.z`; пусто = номер тега. Для ветки задайте вручную;
   - галочки патчей и `run_tests`.
3. Заберите артефакт `patched-packages-<версия>`: внутри `forkop_<версия>_all.ipk/apk`,
   `luci-app-forkop_...`, `luci-i18n-forkop-ru_...`, `install.sh`, `release.json`, `SHA256SUMS`.

Ядро `sing-box-forkop` не пересобирается — ставится отдельно, как у официального Forkop.

## Установка на роутер

```sh
# OpenWrt 25.12 и новее (apk)
scp forkop_2.0.1_all.apk luci-app-forkop_2.0.1_all.apk luci-i18n-forkop-ru_2.0.1_all.apk root@192.168.8.8:/tmp/
ssh root@192.168.8.8 'apk add --allow-untrusted --no-network --repositories-file /dev/null /tmp/forkop_*_all.apk /tmp/luci-app-forkop_*_all.apk /tmp/luci-i18n-forkop-ru_*_all.apk'

# OpenWrt 24.10 (opkg)
ssh root@192.168.8.8 'opkg install /tmp/forkop_*_all.ipk /tmp/luci-app-forkop_*_all.ipk /tmp/luci-i18n-forkop-ru_*_all.ipk'
```

## Нюансы

- Патчи накладываются `git apply`, при расхождении контекста на будущих версиях —
  `patch -p1 --fuzz=10`. Шаблон `forkop.pot` в патчи не входит: workflow регенерирует
  его из исходников. Переводы трёх новых строк едут в `forkop.po`; если на какой-то
  будущей версии патч к po не ляжет, строки станут английскими — верните их руками.
- Тесты (`run_tests`) падают, если патч перестал подходить к новым исходникам, — но
  сборка при этом всё равно выполнится, артефакты будут.
- Версия ядра: проверьте, что установленная `sing-box-forkop` удовлетворяет
  `SB_REQUIRED_VERSION` из `forkop/files/usr/lib/core/constants.uc` новой версии.
