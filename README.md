# Multitools

Утилита в меню-баре macOS: радиальное меню по ⌥K с инструментами — перевод текста
и скриншота, Ask AI, проверка грамматики. Модели работают локально через Ollama.

## Структура

```
multitools/
├── App/                  @main и единственный composition root
├── Domain/               модели без UI: AppAction, TranslationLanguage, ScreenshotTranslation
├── Core/                 общее ядро, не зависящее от конкретного экрана
│   ├── Actions/          фасад действий: ActionPerforming, ActionDispatcher, ActionRouter
│   ├── AI/               AIProviding + реализация Ollama
│   ├── Design/           DesignTokens и переиспользуемые компоненты
│   ├── Presentation/     алерты, описание окна, атрибуты действий (иконки/цвета/подписи)
│   ├── Screen/           ScreenCaptureKit, оверлей выделения области, Vision OCR
│   ├── System/           глобальный хоткей
│   ├── Text/             промпты и валидация текста
│   └── Windows/          менеджер окон инструментов
├── Features/             по папке на инструмент: AskAI, Grammar, RadialMenu, Settings, Translate
└── PreviewSupport/       заглушки для SwiftUI-превью (DEBUG)
```

## Правила зависимостей

Направление — `Domain` ← `Core` ← `Features` ← `App`:

- `Domain` не импортирует SwiftUI и AppKit. Всё, что про внешний вид (иконка, цвет,
  заголовок окна), живёт в `Core/Presentation/AppActionPresentation.swift`.
- Фича не создаёт сервисы сама: зависимости приходят в `init` через протоколы
  (`ActionPerforming`, `WindowPresenting`, `AlertPresenting`), поэтому превью
  подменяет их заглушкой без сети и без захвата экрана.
- Граф объектов собирается только в `App/MultitoolsApp.init()`. Второй экземпляр
  сервиса, созданный по месту, — ошибка структуры.
- Код, нужный двум фичам, опускается в `Core`, а не копируется.
- Внешняя система (Ollama, окна, OCR) — всегда за протоколом.

## Как добавить инструмент

1. Кейс в `Domain/AppAction.swift` (и `group`, если действие уходит в подменю).
2. Подписи и оформление — в `Core/Presentation/AppActionPresentation.swift`.
3. Метод в `ActionPerforming` + реализация в `ActionDispatcher` и `PreviewDispatcher`.
4. Ветка в `ActionRouter.open(_:)` — `switch` исчерпывающий, забыть кейс не даст компилятор.
5. Экран — `Features/<Инструмент>/`.

## Проект

Файлы лежат в `PBXFileSystemSynchronizedRootGroup`: новые файлы внутри `multitools/`
попадают в таргет сами, править `project.pbxproj` не нужно. Единственное исключение —
`Info.plist`, он подключён через `INFOPLIST_FILE` и исключён из Copy Bundle Resources.

Сборка без подписи:

```sh
xcodebuild -project multitools.xcodeproj -scheme multitools \
  -configuration Debug -destination 'platform=macOS' build CODE_SIGN_IDENTITY="-"
```
