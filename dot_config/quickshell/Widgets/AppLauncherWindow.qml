import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets as QSW
import qs.Theme

FloatingWindow {
    id: win
    title: "App Launcher"
    visible: false
    implicitWidth: 760
    implicitHeight: 560
    color: "transparent"

    property var apps: []
    property string query: ""
    property int selectedIndex: 0
    property bool mouseWasInside: false
    property var filteredApps: apps.filter(function(app) {
        const q = query.toLowerCase()
        return q.length === 0 || app.name.toLowerCase().indexOf(q) >= 0 || app.comment.toLowerCase().indexOf(q) >= 0 || app.id.toLowerCase().indexOf(q) >= 0
    })

    function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }
    function focusSearch() { Qt.callLater(function() { search.focus = true; search.forceActiveFocus(); search.cursorPosition = search.text.length }) }
    function clampIndex(index) { if (filteredApps.length === 0) return 0; return Math.max(0, Math.min(filteredApps.length - 1, index)) }
    function selectIndex(index) { selectedIndex = clampIndex(index) }
    function open() { mouseWasInside = false; query = ""; visible = true; refresh(); focusSearch() }
    function toggle() { visible = !visible; if (visible) { mouseWasInside = false; query = ""; refresh(); focusSearch() } }
    function refresh() { appList.running = true }
    function launchSelected() {
        if (filteredApps.length === 0) return
        const id = filteredApps[selectedIndex].id
        const hist = Quickshell.env("HOME") + "/.cache/quickshell/app-launcher-history"
        launchProcess.command = ["bash", "-lc", "mkdir -p ~/.cache/quickshell; { printf '%s\\n' " + shellQuote(id) + "; grep -vxF " + shellQuote(id) + " " + shellQuote(hist) + " 2>/dev/null | head -n 29; } > " + shellQuote(hist + ".tmp") + " && mv " + shellQuote(hist + ".tmp") + " " + shellQuote(hist) + "; gtk-launch " + shellQuote(id)]
        launchProcess.running = true
        visible = false
    }

    onQueryChanged: { selectedIndex = 0; focusSearch() }
    onFilteredAppsChanged: selectedIndex = clampIndex(selectedIndex)
    onSelectedIndexChanged: if (visible) Qt.callLater(function() { list.positionViewAtIndex(selectedIndex, ListView.Contain) })

    IpcHandler {
        target: "appLauncher"
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
            if (event.key === Qt.Key_Backspace && !search.activeFocus && win.query.length > 0) { win.query = win.query.slice(0, -1); win.focusSearch(); event.accepted = true }
            else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) { win.selectIndex(win.selectedIndex + 1); event.accepted = true }
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) { win.selectIndex(win.selectedIndex - 1); event.accepted = true }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { win.launchSelected(); event.accepted = true }
            else if (event.key === Qt.Key_Escape) { win.visible = false; event.accepted = true }
        }

        Keys.onPressed: function(event) { root.handleKey(event) }

        MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; onEntered: win.mouseWasInside = true; onExited: if (win.mouseWasInside) win.visible = false }
        Rectangle { anchors.fill: parent; radius: 34; color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.13); border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.38); border.width: 1 }

        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 28; height: 52; radius: 21
            color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.50)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
            Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 16; text: "󰍉"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize + 5; color: Theme.mauve }
            TextInput {
                id: search
                focus: true
                activeFocusOnTab: true
                anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 50; anchors.rightMargin: 16
                text: win.query
                onTextChanged: win.query = text
                clip: true
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize + 2
                color: Theme.text
                selectionColor: Theme.mauve
                selectedTextColor: Theme.base
                Text { visible: search.text.length === 0; text: "Launch app…"; font: search.font; color: Theme.overlay1 }
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
            anchors.leftMargin: 28; anchors.rightMargin: 28; anchors.topMargin: 96; anchors.bottomMargin: 14
            model: win.filteredApps
            spacing: 10
            clip: true
            currentIndex: win.selectedIndex
            delegate: Rectangle {
                id: card
                width: list.width
                height: 68
                radius: 20
                color: index === win.selectedIndex ? Qt.rgba(Theme.mauve.r, Theme.mauve.g, Theme.mauve.b, 0.22) : Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.45)
                border.color: index === win.selectedIndex ? Theme.mauve : Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
                border.width: index === win.selectedIndex ? 2 : 1
                antialiasing: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    width: 44
                    height: 44
                    radius: 14
                    color: Qt.rgba(Theme.surface0.r, Theme.surface0.g, Theme.surface0.b, 0.72)

                    QSW.IconImage {
                        id: appIcon
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: modelData.icon ? "image://icon/" + modelData.icon : ""
                        asynchronous: true
                        mipmap: true
                    }

                    Text {
                        visible: appIcon.status === Image.Error || appIcon.source === ""
                        anchors.centerIn: parent
                        text: modelData.name.length ? modelData.name[0].toUpperCase() : "?"
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pixelSize: Theme.fontPixelSize + 7
                        color: Theme.mauve
                    }
                }
                ColumnLayout {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 70; anchors.rightMargin: 14
                    spacing: 2
                    Text { Layout.fillWidth: true; text: modelData.name; elide: Text.ElideRight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize + 1; font.bold: true; color: Theme.text }
                    Text { Layout.fillWidth: true; text: (modelData.used ? "Recent · " : "") + (modelData.comment || modelData.id); elide: Text.ElideRight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize - 2; color: modelData.used ? Theme.green : Theme.overlay2 }
                }
                MouseArea { anchors.fill: parent; onClicked: { if (index === win.selectedIndex) win.launchSelected(); else win.selectIndex(index); search.forceActiveFocus() } }
            }
        }

        Rectangle {
            id: footer
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            anchors.leftMargin: 42; anchors.rightMargin: 42; anchors.bottomMargin: 22
            height: 44; radius: 18
            color: Qt.rgba(Theme.crust.r, Theme.crust.g, Theme.crust.b, 0.42)
            border.color: Qt.rgba(Theme.surface1.r, Theme.surface1.g, Theme.surface1.b, 0.45)
            Text { anchors.centerIn: parent; text: win.filteredApps.length + " apps · type search · ↑/↓ select · Enter launch · Esc"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontPixelSize - 2; color: Theme.overlay2 }
        }
    }

    Process {
        id: appList
        running: false
        command: ["python3", "-c", "import configparser,glob,os,json;\nseen={};\nhist_path=os.path.expanduser('~/.cache/quickshell/app-launcher-history');\nhist=[]\ntry:\n    hist=[x.strip() for x in open(hist_path, encoding='utf-8') if x.strip()]\nexcept Exception:\n    pass\nrank={v:i for i,v in enumerate(hist)}\npaths=glob.glob('/usr/share/applications/*.desktop')+glob.glob(os.path.expanduser('~/.local/share/applications/*.desktop'));\nfor p in paths:\n    cp=configparser.ConfigParser(interpolation=None); cp.optionxform=str\n    try: cp.read(p, encoding='utf-8')\n    except Exception: continue\n    if not cp.has_section('Desktop Entry'): continue\n    d=cp['Desktop Entry']\n    if d.get('Type','Application')!='Application' or d.get('NoDisplay','false').lower()=='true' or d.get('Hidden','false').lower()=='true': continue\n    name=d.get('Name','').strip()\n    if not name: continue\n    did=os.path.basename(p)\n    appid=did[:-8] if did.endswith('.desktop') else did\n    seen[appid]={'id':appid,'name':name,'comment':d.get('Comment','').strip(),'icon':d.get('Icon','').strip(),'used': appid in rank}\nprint(json.dumps(sorted(seen.values(), key=lambda x:(rank.get(x['id'],999999), x['name'].lower()))))"]
        stdout: StdioCollector { onStreamFinished: { try { win.apps = JSON.parse(text) } catch(e) { win.apps = [] }; win.selectedIndex = 0 } }
    }
    Process { id: launchProcess; running: false }
}
