import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Theme

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property string downText: "—"
    property string upText: "—"

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 8

        Text {
            text: "\uF437"
            font.pixelSize: Theme.fontPixelSize
            font.family: Theme.fontFamily
            color: Theme.peach
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: "\uF0AB"
            font.pixelSize: Theme.fontPixelSize
            font.family: Theme.fontFamily
            color: Theme.peach
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            Layout.preferredWidth: 44
            Layout.alignment: Qt.AlignVCenter
            text: downText
            font.pixelSize: Theme.fontPixelSize
            font.family: Theme.fontFamily
            color: Theme.peach
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            text: "\uF0AA"
            font.pixelSize: Theme.fontPixelSize
            font.family: Theme.fontFamily
            color: Theme.peach
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            Layout.preferredWidth: 44
            Layout.alignment: Qt.AlignVCenter
            text: upText
            font.pixelSize: Theme.fontPixelSize
            font.family: Theme.fontFamily
            color: Theme.peach
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
    }

    Process {
        id: process
        command: ["sh", "-c", "awk 'NR>2 && $1!~/^lo:/ {rx+=$2; tx+=$10} END{print rx+0, tx+0}' /proc/net/dev; sleep 1; awk 'NR>2 && $1!~/^lo:/ {rx+=$2; tx+=$10} END{print rx+0, tx+0}' /proc/net/dev"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var lines = text.trim().split("\n")
                if (lines.length >= 2) {
                    var p1 = lines[0].split(/\s+/), p2 = lines[1].split(/\s+/)
                    var rx1 = parseInt(p1[0], 10) || 0, tx1 = parseInt(p1[1], 10) || 0
                    var rx2 = parseInt(p2[0], 10) || 0, tx2 = parseInt(p2[1], 10) || 0
                    var down = Math.max(0, rx2 - rx1), up = Math.max(0, tx2 - tx1)
                    function fmt(bytesPerSec) {
                        var bps = bytesPerSec * 8
                        if (bps >= 1e6) return (bps / 1e6).toFixed(1) + "Mb"
                        if (bps >= 1e3) return (bps / 1e3).toFixed(0) + "Kb"
                        return bps + "b"
                    }
                    root.downText = fmt(down)
                    root.upText = fmt(up)
                }
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true
}
