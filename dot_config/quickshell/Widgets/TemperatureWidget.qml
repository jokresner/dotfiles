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
        command: ["sh", "-c", root.hwmonPath ? ("cat " + root.hwmonPath + " 2>/dev/null | awk '{print int($1/1000)}'") : "for d in /sys/class/hwmon/hwmon*; do [ -f \"$d/name\" ] || continue; n=$(cat \"$d/name\" 2>/dev/null); case \"$n\" in coretemp|k10temp|zenpower|k8temp) for f in \"$d\"/temp*_input; do [ -f \"$f\" ] && echo $(($(cat \"$f\")/1000)) && exit 0; done;; esac; done"]
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
