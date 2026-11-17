# Multitools

Утилита в меню-баре macOS: радиальное меню по ⌥K с инструментами — перевод текста
и скриншота, Ask AI, проверка грамматики. Модели работают локально через Ollama.

## Структура

```
multitools/
├── App/                  @main и единственный composition root
├── Domain/               модели без UI: AppAction, TranslationLanguage,
│                         доменные ошибки захвата и чтения текста со снимка
├── Core/                 общее ядро, не зависящее от конкретного экрана
│   ├── Actions/          узкие роли действий (ActionPorts), ActionRouter, FeatureViewFactory,
│   │                     ScreenshotTextReader
│   ├── AI/               AIProviding + реализация Ollama
│   ├── Components/       переиспользуемые SwiftUI-компоненты
│   ├── Config/           токены оформления: RadialMenuTokens, ToolWindowTokens, FeedbackTokens,
│   │                     PanelTokens, расширение Color(hex:), атрибуты действий (иконка/заголовок)
│   ├── Presentation/     алерты и описание окна инструмента
│   ├── Screen/           порты ScreenCapturing/TextRecognizing, ScreenService, геометрия,
│   │                     права на запись экрана, оверлей выделения, Vision OCR
│   ├── System/           глобальный хоткей, промпты и валидация текста, буфер обмена
│   └── Windows/          менеджер окон инструментов
├── Features/             экраны инструментов и радиальное меню
└── PreviewSupport/       заглушки для SwiftUI-превью (DEBUG)
```

## Правила зависимостей

Направление — `Domain` ← `Core` ← `Features` ← `App`:

- `Domain` не импортирует SwiftUI и AppKit. Всё, что про внешний вид (иконка пункта
  меню, заголовок окна), живёт в `Core/Config/AppActionPresentation.swift`.
- Фича не создаёт сервисы сама: зависимости приходят в `init` через протоколы
  (`Translating`, `Explaining`, `GrammarChecking`, `WindowPresenting`, `AlertPresenting`),
  поэтому превью подменяет их заглушкой без сети и без захвата экрана. Каждый экран
  принимает только свою роль, а не общий фасад действий.
- Граф объектов собирается только в `App/MultitoolsApp.init()`. Второй экземпляр
  сервиса, созданный по месту, — ошибка структуры.
- Код, нужный двум фичам, опускается в `Core`, а не копируется.
- Внешняя система (Ollama, окна, OCR) — всегда за протоколом.

## Как добавить инструмент

1. Кейс в `Domain/AppAction.swift` (и `group`, если действие уходит в подменю).
2. Подписи и оформление — в `Core/Config/AppActionPresentation.swift`.
3. Если нужно новое действие ИИ — протокол в `Core/Actions/ActionPorts.swift`,
   реализация в сервисе и заглушка в `PreviewDispatcher`.
4. Ветка в `ActionRouter.open(_:)` и в `FeatureViewFactory.view(for:)` — оба `switch`
   исчерпывающие, забыть кейс не даст компилятор.
5. Экран — `Features/`.

## Проект

Файлы лежат в `PBXFileSystemSynchronizedRootGroup`: новые файлы внутри `multitools/`
попадают в таргет сами, править `project.pbxproj` не нужно. Единственное исключение —
`Info.plist`, он подключён через `INFOPLIST_FILE` и исключён из Copy Bundle Resources.

Сборка без подписи:

```sh
xcodebuild -project multitools.xcodeproj -scheme multitools \
  -configuration Debug -destination 'platform=macOS' build CODE_SIGN_IDENTITY="-"
```
