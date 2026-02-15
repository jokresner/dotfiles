import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "\uE266   —%"
        font.pixelSize: Theme.fontPixelSize
        font.family: Theme.fontFamily
        color: Theme.rosewater
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: process
        command: ["sh", "-c", "awk '/cpu / {u=$2+$4; t=$2+$4+$5; print int(0.5+100*u/t)}' /proc/stat"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var v = text.trim()
                label.text = "\uE266   " + (v || "—") + "%"
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true
}
