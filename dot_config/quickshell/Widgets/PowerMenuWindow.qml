import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme

FloatingWindow {
    id: win
    title: "Power Menu"
    visible: false
    implicitWidth: 820
    implicitHeight: 340
    color: "transparent"

    property int selectedIndex: 0
    property int armedIndex: -1
    property bool mouseWasInside: false
    readonly property var actions: [
        { name: "Lock", icon: "", hint: "hyprlock", cmd: "hyprlock", danger: false },
        { name: "Logout", icon: "󰗼", hint: "Hyprland exit", cmd: "hyprctl dispatch exit", danger: true },
        { name: "Suspend", icon: "󰤄", hint: "systemctl suspend", cmd: "systemctl suspend", danger: false },
        { name: "Reboot", icon: "󰜉", hint: "systemctl reboot", cmd: "systemctl reboot", danger: true },
        { name: "Shutdown", icon: "󰐥", hint: "systemctl poweroff", cmd: "systemctl poweroff", danger: true }
    ]

    function clampIndex(index) { return ((index % actions.length) + actions.length) % actions.length }
    function selectIndex(index) { selectedIndex = clampIndex(index); armedIndex = -1 }
    function open() { mouseWasInside = false; armedIndex = -1; visible = true; keyScope.forceActiveFocus() }
    function toggle() { visible = !visible; if (visible) { mouseWasInside = false; armedIndex = -1; keyScope.forceActiveFocus() } }
    function runAction(index) {
        const action = actions[index]
        if (action.danger && armedIndex !== index) { armedIndex = index; return }
        actionProcess.command = ["bash", "-lc", action.cmd]
        actionProcess.running = true
        visible = false
        armedIndex = -1
    }

    IpcHandler {
        target: "powerMenu"
        function open() { win.open() }
        function toggle() { win.toggle() }
        function lock() { win.runAction(0) }
        function logout() { win.runAction(1) }
        function suspend() { win.runAction(2) }
        function reboot() { win.runAction(3) }
        function shutdown() { win.runAction(4) }
    }

    Item {
        id: keyScope
        anchors.fill: parent
        focus: win.visible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left || event.key === Qt.Key_H) { win.selectIndex(win.selectedIndex - 1); event.accepted = true }
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) { win.selectIndex(win.selectedIndex + 1); event.accepted = true }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) { win.runAction(win.selectedIndex); event.accepted = true }
            else if (event.key === Qt.Key_Escape) { win.visible = false; event.accepted = true }
        }

        MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; onEntered: win.mouseWasInside = true; onExited: if (win.mouseWasInside) win.visible = false }

        Rectangle { anchors.fill: parent; radius: 34; color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.13); border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.38); border.width: 1 }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 16
            Repeater {
                model: win.actions.length
                Rectangle {
                    id: card
                    property var action: win.actions[index]
                    property bool selected: index === win.selectedIndex
                    property bool armed: index === win.armedIndex
                    width: selected ? 150 : 126
                    height: selected ? 190 : 162
                    radius: selected ? 28 : 24
                    y: selected ? -10 : 4
                    color: armed ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.28) : Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.70)
                    border.color: armed ? Theme.red : selected ? Theme.mauve : Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.60)
                    border.width: selected ? 3 : 1
                    antialiasing: true

                    Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 100 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8
                        Text { Layout.alignment: Qt.AlignHCenter; text: card.action.icon; font.family: Theme.fontFamily; font.pixelSize: card.selected ? 46 : 36; color: card.armed ? Theme.red : Theme.text }
                        Text { Layout.alignment: Qt.AlignHCenter; text: card.action.name; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize + 2; font.bold: true; color: Theme.text }
                        Text { Layout.fillWidth: true; text: card.armed ? "Press Enter again" : card.action.hint; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize - 3; color: card.armed ? Theme.red : Theme.overlay2 }
                    }
                    MouseArea { anchors.fill: parent; onClicked: { if (card.selected) win.runAction(index); else win.selectIndex(index); keyScope.forceActiveFocus() } }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            anchors.leftMargin: 42; anchors.rightMargin: 42; anchors.bottomMargin: 22
            height: 44; radius: 18
            color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.42)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
            Text { anchors.centerIn: parent; text: "←/→ select · Enter apply" + (win.armedIndex >= 0 ? " again · Esc cancel" : " · Esc close"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize - 1; color: Theme.text }
        }
    }

    Process { id: actionProcess; running: false }
}
