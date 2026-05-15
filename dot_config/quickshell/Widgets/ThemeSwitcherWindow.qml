import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme

FloatingWindow {
    id: win
    title: "Theme Switcher"
    visible: false
    implicitWidth: 920
    implicitHeight: 460
    color: "transparent"

    property string scriptsDir: Quickshell.env("HOME") + "/.config/nushell/scripts"
    property string currentTheme: "—"
    property int selectedIndex: currentTheme === "latte" ? 2 : currentTheme === "mocha" ? 1 : 0
    property bool mouseWasInside: false
    readonly property var modes: ["auto", "mocha", "latte"]
    readonly property var names: ["Auto", "Mocha", "Latte"]
    readonly property var subtitles: ["Follow darkman / system", "Catppuccin dark", "Catppuccin light"]

    function clampIndex(index) {
        return ((index % modes.length) + modes.length) % modes.length
    }

    function selectIndex(index) {
        selectedIndex = clampIndex(index)
    }

    function selectedMode() {
        return modes[selectedIndex]
    }

    function selectedName() {
        return names[selectedIndex]
    }

    function modeForOffset(offset) {
        return modes[clampIndex(selectedIndex + offset)]
    }

    function nameForMode(mode) {
        const idx = modes.indexOf(mode)
        return idx >= 0 ? names[idx] : mode
    }

    function subtitleForMode(mode) {
        const idx = modes.indexOf(mode)
        return idx >= 0 ? subtitles[idx] : ""
    }

    function open() {
        mouseWasInside = false
        visible = true
        refresh()
        keyScope.forceActiveFocus()
    }

    function toggle() {
        visible = !visible
        if (visible) {
            mouseWasInside = false
            refresh()
            keyScope.forceActiveFocus()
        }
    }

    function refresh() { themeState.running = true }

    function runTheme(mode) {
        themeApply.command = [scriptsDir + "/theme-switch.nu", "--" + mode]
        themeApply.running = true
        visible = false
    }

    function applySelected() {
        runTheme(selectedMode())
    }

    IpcHandler {
        target: "themeSwitcher"
        function open() { win.open() }
        function toggle() { win.toggle() }
        function autoTheme() { win.runTheme("auto") }
        function mocha() { win.runTheme("mocha") }
        function latte() { win.runTheme("latte") }
    }

    Item {
        id: keyScope
        anchors.fill: parent
        focus: win.visible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                win.selectIndex(win.selectedIndex - 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                win.selectIndex(win.selectedIndex + 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                win.applySelected()
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                win.visible = false
                event.accepted = true
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: win.mouseWasInside = true
            onExited: if (win.mouseWasInside) win.visible = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 34
            color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.13)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.38)
            border.width: 1
        }

        Item {
            id: carousel
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 24
            anchors.bottomMargin: 76
            clip: false

            Repeater {
                model: [-1, 0, 1]

                ThemeCard {
                    id: card
                    property int offset: modelData
                    property string mode: win.modeForOffset(offset)
                    property bool centered: offset === 0

                    width: centered ? 430 : 330
                    height: centered ? 300 : 230
                    x: carousel.width / 2 - width / 2 + offset * 260
                    y: carousel.height / 2 - height / 2
                    z: centered ? 20 : 10

                    modeName: win.nameForMode(mode)
                    subtitle: win.subtitleForMode(mode)
                    themeMode: mode
                    active: mode === win.currentTheme
                    selected: centered

                    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

                    onClicked: {
                        if (centered) win.applySelected()
                        else win.selectIndex(win.selectedIndex + offset)
                        keyScope.forceActiveFocus()
                    }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 42
            anchors.rightMargin: 42
            anchors.bottomMargin: 22
            height: 48
            radius: 20
            color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.42)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: win.selectedName() + " · Current: " + win.currentTheme
                    elide: Text.ElideMiddle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize
                    color: Theme.text
                }

                Text {
                    text: (win.selectedIndex + 1) + " / 3 · ←/→ select · Enter apply · Esc"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize - 2
                    color: Theme.overlay2
                }
            }
        }
    }

    component ThemeCard: Rectangle {
        id: card
        property string modeName: ""
        property string subtitle: ""
        property string themeMode: "mocha"
        property bool active: false
        property bool selected: false
        signal clicked()

        radius: selected ? 30 : 26
        color: card.themeMode === "latte" ? "#eff1f5" : card.themeMode === "mocha" ? "#1e1e2e" : Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.88)
        border.color: selected ? Theme.mauve : active ? Theme.green : Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.65)
        border.width: selected ? 3 : 1
        opacity: selected ? 1.0 : 0.86
        antialiasing: true

        property color fg: themeMode === "latte" ? "#4c4f69" : "#cdd6f4"
        property color sub: themeMode === "latte" ? "#6c6f85" : "#bac2de"
        property color base: themeMode === "latte" ? "#eff1f5" : "#1e1e2e"
        property color crust: themeMode === "latte" ? "#dce0e8" : "#11111b"
        property color surface: themeMode === "latte" ? "#ccd0da" : "#313244"
        property color accent: themeMode === "latte" ? "#8839ef" : "#cba6f7"
        property color blue: themeMode === "latte" ? "#1e66f5" : "#89b4fa"
        property color green: themeMode === "latte" ? "#40a02b" : "#a6e3a1"
        property color peach: themeMode === "latte" ? "#fe640b" : "#fab387"
        property int dotSize: selected ? 28 : 18
        property int dotGap: selected ? 8 : 5

        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 12
            radius: card.radius - 8
            color: Qt.rgba(card.crust.r, card.crust.g, card.crust.b, 0.72)
            border.color: Qt.rgba(card.surface.r, card.surface.g, card.surface.b, 0.88)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: card.selected ? 18 : 14
                spacing: card.selected ? 12 : 9

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: card.modeName
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontPixelSize + (card.selected ? 8 : 3)
                        font.bold: true
                        color: card.fg
                    }

                    Rectangle {
                        visible: card.active
                        width: 34
                        height: 34
                        radius: 17
                        color: Qt.rgba(card.green.r, card.green.g, card.green.b, 0.92)
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontPixelSize + 2
                            color: card.base
                        }
                    }
                }

                Text {
                    text: card.subtitle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize - 1
                    color: card.sub
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: card.base
                        border.color: card.surface

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 12
                            width: parent.width * 0.24
                            radius: 13
                            color: card.crust
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            height: 26
                            radius: 13
                            color: card.surface
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: parent.width * 0.32
                            anchors.rightMargin: 16
                            anchors.topMargin: 52
                            anchors.bottomMargin: 16
                            spacing: 10

                            Rectangle { width: parent.width * 0.78; height: 18; radius: 9; color: card.accent }
                            Rectangle { width: parent.width; height: 16; radius: 8; color: card.surface }
                            Rectangle { width: parent.width * 0.64; height: 16; radius: 8; color: card.surface }

                        }

                        Row {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: 16
                            anchors.bottomMargin: card.selected ? 16 : 30
                            spacing: card.dotGap
                            Rectangle { width: card.dotSize; height: card.dotSize; radius: card.dotSize / 2; color: card.accent }
                            Rectangle { width: card.dotSize; height: card.dotSize; radius: card.dotSize / 2; color: card.blue }
                            Rectangle { width: card.dotSize; height: card.dotSize; radius: card.dotSize / 2; color: card.green }
                            Rectangle { width: card.dotSize; height: card.dotSize; radius: card.dotSize / 2; color: card.peach }
                        }

                        Rectangle {
                            visible: card.themeMode === "auto"
                            anchors.fill: parent
                            radius: 18
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#eff1f5" }
                                GradientStop { position: 0.48; color: "#eff1f5" }
                                GradientStop { position: 0.52; color: "#1e1e2e" }
                                GradientStop { position: 1.0; color: "#1e1e2e" }
                            }
                            opacity: 0.28
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: card.clicked()
        }
    }

    Process { id: themeApply; running: false; onExited: win.refresh() }
    Process {
        id: themeState
        command: ["sh", "-c", "cat ~/.config/current-theme 2>/dev/null || echo unknown"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                win.currentTheme = text.trim()
                win.selectedIndex = win.currentTheme === "latte" ? 2 : win.currentTheme === "mocha" ? 1 : win.selectedIndex
            }
        }
    }
}
