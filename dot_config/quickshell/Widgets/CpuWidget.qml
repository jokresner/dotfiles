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
        command: ["sh", "-c", "read cpu user nice sys idle iowait irq softirq steal guest guest_nice < /proc/stat; idle1=$((idle+iowait)); nonidle1=$((user+nice+sys+irq+softirq+steal)); total1=$((idle1+nonidle1)); sleep 1; read cpu user nice sys idle iowait irq softirq steal guest guest_nice < /proc/stat; idle2=$((idle+iowait)); nonidle2=$((user+nice+sys+irq+softirq+steal)); total2=$((idle2+nonidle2)); totald=$((total2-total1)); idled=$((idle2-idle1)); [ \"$totald\" -gt 0 ] && printf '%s\\n' $(((1000*(totald-idled)/totald + 5)/10)) || printf '0\\n'"]
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
        interval: 2000
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true
}
