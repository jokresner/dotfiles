import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "\uF0A0   —"
        font.pixelSize: Theme.fontPixelSize
        font.family: Theme.fontFamily
        color: Theme.text
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: process
        command: ["sh", "-c", "df -h -P -l / | awk 'NR==2 {gsub(/%/,\"\",$5); print $5 \" \" $4}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var parts = text.trim().split(/\s+/)
                var pct = parts[0] || "—"
                var avail = parts[1] || ""
                label.text = "\uF0A0   " + (avail ? avail : pct + "%")
                var n = parseInt(pct, 10)
                if (!isNaN(n)) {
                    if (n >= 90) label.color = Theme.red
                    else if (n >= 80) label.color = Theme.yellow
                    else label.color = Theme.text
                }
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 60000
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true
}
