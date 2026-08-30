# Агат

Чёрный кот с золотыми глазами. ИИ-чат: пишешь — отвечает.

**Пакет:** `com.thekingoffamily.agat`  
**Магазин:** RuStore · бесплатно · 0+  
**Модель:** мини Beorn (`gemma4:e4b`) через MasterServer. Ключ не в APK.

Один экран, анимация кота и «печатает». Баннер РСЯ (пока демо `demo-banner-yandex`).

```
cd app
flutter pub get
flutter test
flutter build apk --release
python ../../scripts/clean-artifacts.py
```

Иконка: `branding/logo-512.png` (512×512, без прозрачности).

## Лицензия

Брать и использовать можно, в том числе в своих приложениях.  
Обязательна видимая ссылка на репозиторий: https://github.com/thekingoffamily/Agat  
Текст: [LICENSE](LICENSE)
