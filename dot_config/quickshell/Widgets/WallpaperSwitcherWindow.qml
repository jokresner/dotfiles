import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets as QSW
import Quickshell.Io
import qs.Theme

FloatingWindow {
    id: win
    title: "Wallpaper Switcher"
    visible: false
    implicitWidth: 1120
    implicitHeight: 520
    color: "transparent"

    property string scriptsDir: Quickshell.env("HOME") + "/.config/nushell/scripts"
    property var wallpapers: []
    property string currentWallpaper: "—"
    property int selectedIndex: 0
    property string selectedWallpaper: wallpapers.length > 0 ? wallpapers[selectedIndex] : ""
    readonly property int cellWidth: 520
    property bool mouseWasInside: false

    function fileUrl(path) {
        if (!path || path === "—") return ""
        return "file://" + path
    }

    function clampIndex(index) {
        if (wallpapers.length === 0) return 0
        return ((index % wallpapers.length) + wallpapers.length) % wallpapers.length
    }

    function selectIndex(index) {
        if (wallpapers.length === 0) return
        selectedIndex = clampIndex(index)
    }

    function selectPath(path) {
        const idx = wallpapers.indexOf(path)
        if (idx >= 0) selectIndex(idx)
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

    function refresh() {
        wallpaperState.running = true
        wallpaperList.running = true
    }

    function applySelected() {
        if (selectedWallpaper) runWallpaper(["--set", selectedWallpaper])
    }

    function runWallpaper(args) {
        wallpaperApply.command = [scriptsDir + "/wallpaper-switch.nu"].concat(args)
        wallpaperApply.running = true
    }

    IpcHandler {
        target: "wallpaperSwitcher"
        function open() { win.open() }
        function toggle() { win.toggle() }
        function random() { win.runWallpaper(["--random"]) }
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
            } else if (event.key === Qt.Key_R) {
                win.runWallpaper(["--random"])
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

        // Transparent glass layer: Hyprland blur handles the background behind this window.
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
            anchors.bottomMargin: 70
            clip: false

            function pathForOffset(offset) {
                if (win.wallpapers.length === 0) return ""
                return win.wallpapers[win.clampIndex(win.selectedIndex + offset)]
            }

            Repeater {
                model: [-1, 0, 1]

                Item {
                    id: cell
                    property int offset: modelData
                    property bool centered: offset === 0
                    property string wallpaperPath: carousel.pathForOffset(offset)
                    property bool current: wallpaperPath === win.currentWallpaper
                    width: centered ? 610 : 500
                    height: centered ? 390 : 320
                    x: carousel.width / 2 - width / 2 + offset * 300
                    y: carousel.height / 2 - height / 2
                    z: centered ? 20 : 10

                    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

                    QSW.ClippingRectangle {
                        id: card
                        anchors.fill: parent
                        radius: centered ? 30 : 26
                        color: Theme.crust
                        border.color: centered ? Theme.mauve : Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.55)
                        border.width: centered ? 3 : 1
                        antialiasing: true
                        contentUnderBorder: true
                        contentInsideBorder: false

                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        Image {
                            anchors.fill: parent
                            source: win.fileUrl(cell.wallpaperPath)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            retainWhileLoading: true
                            smooth: true
                            mipmap: true
                        }

                        Rectangle {
                            visible: cell.current
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 16
                            width: 36
                            height: 36
                            radius: 18
                            color: Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.92)
                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontPixelSize + 3
                                color: Theme.base
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (cell.centered) win.applySelected()
                            else win.selectIndex(win.selectedIndex + cell.offset)
                            keyScope.forceActiveFocus()
                        }
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
                    text: win.selectedWallpaper ? win.selectedWallpaper.split('/').pop() : "No wallpapers found"
                    elide: Text.ElideMiddle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize
                    color: Theme.text
                }

                Text {
                    text: (win.wallpapers.length > 0 ? (win.selectedIndex + 1) + " / " + win.wallpapers.length + " · " : "") + "←/→ · Enter apply · R random · Esc"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontPixelSize - 2
                    color: Theme.overlay2
                }
            }
        }
    }

    Process {
        id: wallpaperApply
        running: false
        onExited: win.refresh()
    }

    Process {
        id: wallpaperState
        command: [scriptsDir + "/wallpaper-switch.nu", "--current"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                win.currentWallpaper = text.trim() || "—"
                if (win.wallpapers.length > 0) win.selectPath(win.currentWallpaper)
            }
        }
    }

    Process {
        id: wallpaperList
        command: [scriptsDir + "/wallpaper-switch.nu", "--list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const oldSelection = win.selectedWallpaper
                    win.wallpapers = JSON.parse(text.trim())
                    win.selectedIndex = win.clampIndex(win.selectedIndex)
                    if (oldSelection && win.wallpapers.indexOf(oldSelection) >= 0) win.selectPath(oldSelection)
                    else win.selectPath(win.currentWallpaper)
                } catch (e) {
                    win.wallpapers = []
                    win.selectedIndex = 0
                }
            }
        }
    }
}
