import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme

Item {
    id: root
    property string hwmonPath: ""  // e.g. /sys/class/hwmon/hwmon2/temp1_input
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "\uF2C8   —°C"
        font.pixelSize: Theme.fontPixelSize
        font.family: Theme.fontFamily
        color: Theme.rosewater
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: process
        command: root.hwmonPath ? ["bash", "/home/johannes/.config/quickshell/scripts/cpu-temp.sh", root.hwmonPath] : ["bash", "/home/johannes/.config/quickshell/scripts/cpu-temp.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var v = text.trim()
                label.text = "\uF2C8   " + (v ? v + "°C" : "—°C")
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 4000
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true
}
