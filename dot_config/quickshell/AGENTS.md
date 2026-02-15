# Quickshell panel – agent guide

This repo is a **Quickshell** config: a Qt/QML Wayland panel (bar + widgets). It uses Quickshell APIs and a shared theme.

## Layout

- **`shell.qml`** – Entry. Uses `Bar` and enables `Quickshell.watchFiles` for reload on change.
- **`Bar/`** – Panel window and bar UI:
  - `Bar.qml` – `PanelWindow` with a `RowLayout`; left/center/right sections use `BarPill`.
  - `BarPill.qml` – Rounded container for a group of widgets (default property `content`).
- **`Theme/`** – Singleton `Theme` (Catppuccin Mocha): colors, `barHeight`, `padding`, `spacing`, `fontPixelSize`, `fontFamily`, `sectionRadius`, etc. All widgets and bar UI should use `Theme` only (no hardcoded colors/sizes).
- **`Widgets/`** – Bar widgets. Each has a `qmldir` entry; Bar imports `qs.Widgets` and instantiates them inside `BarPill`s.

## Conventions

1. **Theme** – Use `import qs.Theme` and reference `Theme.*` for colors, fonts, and layout constants.
2. **Widget root** – Widgets are typically `Item` with `implicitWidth`/`implicitHeight` from a main child (e.g. a `Text`).
3. **Icons** – Nerd Font codepoints in `Text` (e.g. `"\uF017   "` for clock). Font: `Theme.fontFamily` ("Fira Code Nerd Font").
4. **Popup/panel** – Widgets that open a popup (e.g. Clock, Tray) take `property var panelWindow: null` and receive the Bar’s `PanelWindow` from `Bar.qml`.
5. **CLI data** – Use Quickshell’s `Process` plus `StdioCollector` on stdout; use a `Timer` to refresh (e.g. every 30s). See `MemoryWidget.qml`.
6. **Bar placement** – To add/move widgets, edit `Bar/Bar.qml`: left section, center (e.g. clock), or right section; each group lives in one `BarPill`.

## Adding a widget

1. Add `YourWidget 1.0 YourWidget.qml` to `Widgets/qmldir`.
2. Implement the widget in `Widgets/YourWidget.qml` (Item root, Theme, implicit size).
3. In `Bar/Bar.qml`, add `YourWidget {}` inside the desired `BarPill` (and set `panelWindow: panel` if it needs a popup).

## Tech

- **Runtime**: Quickshell (Qt 6, QML, Wayland). Entry is `shell.qml`; pragmas at top (e.g. `UseQApplication`, `Env QT_QPA_PLATFORM=wayland`).
- **Modules**: `qs.Bar`, `qs.Theme`, `qs.Widgets` – each has a `qmldir` in its folder.
