# Таблица умножения

Android-приложение, которое помогает ребёнку выучить таблицу умножения: правило для каждого числа, рифмы и картинки для трудных примеров, тест с подсказкой в три шага.

- `app/assets/index.html` — всё приложение (HTML/JS), работает без интернета
- `app/src/…/MainActivity.java` — оболочка WebView
- `build.sh` — собирает `umnozhenie.apk` (для установки напрямую) и `umnozhenie.aab` (для Google Play); ключ загрузки не хранится в репозитории
- `store/` — тексты и картинки для Google Play
- `docs/privacy.html` — политика конфиденциальности (GitHub Pages)

Шрифт Neucha © Jovanny Lemonad, SIL Open Font License 1.1 (`app/assets/OFL.txt`).
