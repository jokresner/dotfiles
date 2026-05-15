import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme

FloatingWindow {
    id: win
    title: "Theme Switcher"
    visible: false
    implicitWidth: 560
    implicitHeight: 340
    color: "transparent"

    property string scriptsDir: Quickshell.env("HOME") + "/.config/nushell/scripts"
    property string currentTheme: "—"

    function open() { visible = true; refresh() }
    function toggle() { visible = !visible; if (visible) refresh() }
    function refresh() { themeState.running = true }
    function runTheme(mode) {
        themeApply.command = [scriptsDir + "/theme-switch.nu", "--" + mode]
        themeApply.running = true
    }

    IpcHandler {
        target: "themeSwitcher"
        function open() { win.open() }
        function toggle() { win.toggle() }
        function autoTheme() { win.runTheme("auto") }
        function mocha() { win.runTheme("mocha") }
        function latte() { win.runTheme("latte") }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.94)
        border.color: Theme.surface1
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "󰔎  Theme"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize + 8
                    color: Theme.text
                }
                Text {
                    text: "×"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize + 10
                    color: Theme.subtext0
                    MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: win.visible = false }
                }
            }

            Text {
                text: "Current: " + win.currentTheme
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontPixelSize
                color: Theme.subtext1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ThemeCard {
                    name: "Auto"
                    subtitle: "darkman / clock"
                    active: false
                    colors: [Theme.mauve, Theme.sky, Theme.peach, Theme.green]
                    onClicked: win.runTheme("auto")
                }

                ThemeCard {
                    name: "Mocha"
                    subtitle: "dark"
                    active: win.currentTheme === "mocha"
                    colors: ["#1e1e2e", "#313244", "#cba6f7", "#89b4fa"]
                    onClicked: win.runTheme("mocha")
                }

                ThemeCard {
                    name: "Latte"
                    subtitle: "light"
                    active: win.currentTheme === "latte"
                    colors: ["#eff1f5", "#ccd0da", "#8839ef", "#1e66f5"]
                    onClicked: win.runTheme("latte")
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Auto follows darkman/GNOME color-scheme; fallback uses clock. Active theme card is highlighted."
                wrapMode: Text.WordWrap
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontPixelSize - 1
                color: Theme.overlay2
            }
        }
    }

    component ThemeCard: Rectangle {
        id: card
        property string name: ""
        property string subtitle: ""
        property bool active: false
        property var colors: []
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 130
        radius: 14
        color: active ? Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.22)
                      : (mouse.containsMouse ? Theme.surface1 : Theme.surface0)
        border.color: active ? Theme.mauve : Theme.surface1
        border.width: active ? 2 : 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: card.name
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize + 2
                    color: Theme.text
                }
                Text {
                    visible: card.active
                    text: "✓"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize + 2
                    color: Theme.green
                }
            }

            Text {
                text: card.subtitle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontPixelSize - 2
                color: Theme.subtext0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Repeater {
                    model: card.colors
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 8
                        color: modelData
                        border.color: Qt.rgba(0, 0, 0, 0.18)
                    }
                }
            }
        }

        MouseArea {
            id: mouse
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
        stdout: StdioCollector { onStreamFinished: win.currentTheme = text.trim() }
    }
}
