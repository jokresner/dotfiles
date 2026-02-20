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
    
    // Internal state for delta calculation
    property real prevRx: 0
    property real prevTx: 0
    property var lastUpdate: 0

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
        command: ["sh", "-c", "awk 'NR>2 && $1!~/^lo:/ {rx+=$2; tx+=$10} END{print rx+0, tx+0}' /proc/net/dev"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var now = Date.now();
                var parts = text.trim().split(/\s+/);
                
                if (parts.length >= 2) {
                    var rx = parseInt(parts[0], 10) || 0;
                    var tx = parseInt(parts[1], 10) || 0;

                    // Only calculate speed if we have a previous data point
                    if (root.prevRx > 0) {
                        var elapsed = (now - root.lastUpdate) / 1000;
                        if (elapsed <= 0) elapsed = 1; // Prevent division by zero

                        var down = (rx - root.prevRx) / elapsed;
                        var up = (tx - root.prevTx) / elapsed;

                        function fmt(bytesPerSec) {
                            var bps = bytesPerSec * 8; // Convert to bits per second
                            if (bps >= 1e6) return (bps / 1e6).toFixed(1) + "Mb";
                            if (bps >= 1e3) return (bps / 1e3).toFixed(0) + "Kb";
                            return bps.toFixed(0) + "b";
                        }
                        
                        root.downText = fmt(down);
                        root.upText = fmt(up);
                    }

                    root.prevRx = rx;
                    root.prevTx = tx;
                    root.lastUpdate = now;
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
