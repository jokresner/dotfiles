import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "\uF2DB   —/—GB"
        font.pixelSize: Theme.fontPixelSize
        font.family: Theme.fontFamily
        color: Theme.rosewater
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: process
        command: ["sh", "-c", "free -g | awk '/^Mem:/ {print $3 \" \" $2}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var parts = text.trim().split(/\s+/)
                var used = parts[0] || "—", total = parts[1] || "—"
                label.text = "\uF2DB   " + used + "/" + total + "GB"
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 30000
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true
}
