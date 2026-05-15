import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme

FloatingWindow {
    id: win
    title: "Clipboard Picker"
    visible: false
    implicitWidth: 760
    implicitHeight: 520
    color: "transparent"

    property var items: []
    property string query: ""
    property int selectedIndex: 0
    property bool mouseWasInside: false
    property var filteredItems: items.filter(function(x) { return query.length === 0 || x.toLowerCase().indexOf(query.toLowerCase()) >= 0 })

    function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }
    function focusSearch() { Qt.callLater(function() { search.focus = true; search.forceActiveFocus(); search.cursorPosition = search.text.length }) }
    function clampIndex(index) { if (filteredItems.length === 0) return 0; return Math.max(0, Math.min(filteredItems.length - 1, index)) }
    function selectIndex(index) { selectedIndex = clampIndex(index) }
    function open() { mouseWasInside = false; query = ""; visible = true; refresh(); focusSearch() }
    function toggle() { visible = !visible; if (visible) { mouseWasInside = false; query = ""; refresh(); focusSearch() } }
    function refresh() { listProcess.running = true }
    function choose() {
        if (filteredItems.length === 0) return
        copyProcess.command = ["bash", "-lc", "printf %s " + shellQuote(filteredItems[selectedIndex]) + " | cliphist decode | wl-copy"]
        copyProcess.running = true
        visible = false
    }
    function removeSelected() {
        if (filteredItems.length === 0) return
        deleteProcess.command = ["bash", "-lc", "printf %s " + shellQuote(filteredItems[selectedIndex]) + " | cliphist delete"]
        deleteProcess.running = true
    }

    onQueryChanged: { selectedIndex = 0; focusSearch() }
    onFilteredItemsChanged: selectedIndex = clampIndex(selectedIndex)
    onSelectedIndexChanged: if (visible) Qt.callLater(function() { list.positionViewAtIndex(selectedIndex, ListView.Contain) })

    IpcHandler {
        target: "clipboardPicker"
        function open() { win.open() }
        function toggle() { win.toggle() }
        function refresh() { win.refresh() }
    }

    FocusScope {
        id: root
        anchors.fill: parent
        focus: win.visible

        function handleKey(event) {
            if (event.text && event.text.length > 0 && event.text >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                if (!search.activeFocus) {
                    win.query += event.text
                    win.focusSearch()
                    event.accepted = true
                }
                return
            }
            if (event.key === Qt.Key_Down || event.key === Qt.Key_J) { win.selectIndex(win.selectedIndex + 1); event.accepted = true }
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) { win.selectIndex(win.selectedIndex - 1); event.accepted = true }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { win.choose(); event.accepted = true }
            else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                if (event.key === Qt.Key_Backspace && search.activeFocus && search.text.length > 0) return
                win.removeSelected(); event.accepted = true
            }
            else if (event.key === Qt.Key_Escape) { win.visible = false; event.accepted = true }
        }

        Keys.onPressed: function(event) { root.handleKey(event) }

        MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; onEntered: win.mouseWasInside = true; onExited: if (win.mouseWasInside) win.visible = false }
        Rectangle { anchors.fill: parent; radius: 34; color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.13); border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.38); border.width: 1 }

        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 28; height: 48; radius: 20
            color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.50)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
            Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 16; text: "󰅌"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize + 3; color: Theme.mauve }
            TextInput {
                id: search
                focus: true
                activeFocusOnTab: true
                anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 48; anchors.rightMargin: 16
                text: win.query
                onTextChanged: win.query = text
                clip: true
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize + 1
                color: Theme.text
                selectionColor: Theme.mauve
                selectedTextColor: Theme.base
                Text { visible: search.text.length === 0; text: "Search clipboard…"; font: search.font; color: Theme.overlay1 }
                Keys.onPressed: function(event) { root.handleKey(event) }
            }
        }

        Timer {
            interval: 60
            repeat: true
            running: win.visible && !search.activeFocus
            onTriggered: win.focusSearch()
        }

        ListView {
            id: list
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: footer.top
            anchors.leftMargin: 28; anchors.rightMargin: 28; anchors.topMargin: 90; anchors.bottomMargin: 14
            model: win.filteredItems
            spacing: 10
            clip: true
            currentIndex: win.selectedIndex
            delegate: Rectangle {
                id: card
                width: list.width
                height: 62
                radius: 18
                color: index === win.selectedIndex ? Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.22) : Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.45)
                border.color: index === win.selectedIndex ? Theme.mauve : Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
                border.width: index === win.selectedIndex ? 2 : 1
                antialiasing: true
                Text {
                    anchors.fill: parent; anchors.margins: 14
                    text: String(modelData).replace(/^\S+\s+/, "")
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize
                    color: Theme.text
                }
                MouseArea { anchors.fill: parent; onClicked: { if (index === win.selectedIndex) win.choose(); else win.selectIndex(index); search.forceActiveFocus() } }
            }
        }

        Rectangle {
            id: footer
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            anchors.leftMargin: 42; anchors.rightMargin: 42; anchors.bottomMargin: 22
            height: 44; radius: 18
            color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.42)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
            Text { anchors.centerIn: parent; text: win.filteredItems.length + " items · type search · ↑/↓ select · Enter copy · Backspace remove · Esc"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize - 2; color: Theme.overlay2 }
        }
    }

    Process {
        id: listProcess
        command: ["bash", "-lc", "cliphist list 2>/dev/null || true"]
        running: false
        stdout: StdioCollector { onStreamFinished: { win.items = text.trim().length ? text.trim().split('\n') : []; win.selectedIndex = 0 } }
    }
    Process { id: copyProcess; running: false }
    Process { id: deleteProcess; running: false; onExited: win.refresh() }
}
