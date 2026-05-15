import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme

FloatingWindow {
    id: win
    title: "Wallpaper Switcher"
    visible: false
    implicitWidth: 920
    implicitHeight: 600
    color: "transparent"

    property string scriptsDir: Quickshell.env("HOME") + "/.config/nushell/scripts"
    property var wallpapers: []
    property string currentWallpaper: "—"
    property string selectedWallpaper: currentWallpaper
    property string searchText: ""
    property var filteredWallpapers: wallpapers.filter(function(path) {
        return searchText === "" || path.toLowerCase().indexOf(searchText.toLowerCase()) !== -1
    })

    function fileUrl(path) {
        if (!path || path === "—") return ""
        return "file://" + path
    }

    function open() { visible = true; refresh(); search.forceActiveFocus() }
    function toggle() { visible = !visible; if (visible) { refresh(); search.forceActiveFocus() } }
    function refresh() { wallpaperState.running = true; wallpaperList.running = true }
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
                    text: "󰸉  Wallpaper"
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
                Layout.fillWidth: true
                text: "Current: " + win.currentWallpaper
                elide: Text.ElideMiddle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontPixelSize
                color: Theme.subtext1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                SwitchButton { text: "Random"; onClicked: win.runWallpaper(["--random"]) }
                SwitchButton { text: "Apply selected"; onClicked: if (win.selectedWallpaper && win.selectedWallpaper !== "—") win.runWallpaper(["--set", win.selectedWallpaper]) }
                SwitchButton { text: "Reload list"; onClicked: wallpaperList.running = true }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 10
                    color: Theme.surface0
                    border.color: Theme.surface1

                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        text: win.searchText
                        color: Theme.text
                        selectionColor: Theme.mauve
                        selectedTextColor: Theme.base
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontPixelSize
                        clip: true
                        onTextChanged: win.searchText = text
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape) {
                                if (text.length > 0) text = ""
                                else win.visible = false
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (win.selectedWallpaper && win.selectedWallpaper !== "—") win.runWallpaper(["--set", win.selectedWallpaper])
                                event.accepted = true
                            }
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: search.text.length === 0
                        text: "Search wallpapers…"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontPixelSize
                        color: Theme.overlay1
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 380
                    Layout.fillHeight: true
                    radius: 12
                    color: Qt.rgba(Theme.surface0.r, Theme.surface0.g, Theme.surface0.b, 0.45)
                    border.color: Theme.surface1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 260
                            radius: 10
                            color: Theme.crust
                            border.color: Theme.surface1
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: win.fileUrl(win.selectedWallpaper)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: win.selectedWallpaper ? win.selectedWallpaper.split('/').pop() : "No wallpaper selected"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideMiddle
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontPixelSize
                            color: Theme.text
                        }

                        Text {
                            Layout.fillWidth: true
                            text: win.selectedWallpaper
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideMiddle
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontPixelSize - 2
                            color: Theme.overlay2
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: Qt.rgba(Theme.surface0.r, Theme.surface0.g, Theme.surface0.b, 0.45)
                    border.color: Theme.surface1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            text: win.filteredWallpapers.length + " / " + win.wallpapers.length + " wallpapers"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontPixelSize - 2
                            color: Theme.overlay2
                        }

                        ListView {
                            id: listView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            model: win.filteredWallpapers
                            clip: true
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 36
                                radius: 8
                                property bool isSelected: modelData === win.selectedWallpaper
                                property bool isCurrent: modelData === win.currentWallpaper
                                color: isSelected ? Theme.surface2 : (mouse.containsMouse ? Theme.surface1 : "transparent")
                                border.color: isCurrent ? Theme.green : "transparent"
                                border.width: isCurrent ? 1 : 0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8

                                    Text {
                                        text: isCurrent ? "✓" : ""
                                        Layout.preferredWidth: 16
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontPixelSize
                                        color: Theme.green
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.split('/').pop()
                                        elide: Text.ElideMiddle
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontPixelSize - 1
                                        color: isSelected ? Theme.base : Theme.text
                                    }
                                }

                                MouseArea {
                                    id: mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: win.selectedWallpaper = modelData
                                    onDoubleClicked: win.runWallpaper(["--set", modelData])
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component SwitchButton: Rectangle {
        id: btn
        property alias text: label.text
        signal clicked()
        implicitWidth: label.implicitWidth + 26
        implicitHeight: 34
        radius: 10
        color: mouse.containsMouse ? Theme.surface1 : Theme.surface0
        border.color: Theme.surface1
        Text { id: label; anchors.centerIn: parent; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize; color: Theme.text }
        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; onClicked: btn.clicked() }
    }

    Process { id: wallpaperApply; running: false; onExited: win.refresh() }
    Process {
        id: wallpaperState
        command: [scriptsDir + "/wallpaper-switch.nu", "--current"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                win.currentWallpaper = text.trim() || "—"
                if (!win.selectedWallpaper || win.selectedWallpaper === "—") win.selectedWallpaper = win.currentWallpaper
            }
        }
    }
    Process {
        id: wallpaperList
        command: [scriptsDir + "/wallpaper-switch.nu", "--list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try { win.wallpapers = JSON.parse(text.trim()) }
                catch (e) { win.wallpapers = [] }
            }
        }
    }
}
