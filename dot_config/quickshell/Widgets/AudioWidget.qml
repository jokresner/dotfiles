import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "\uF028   —%"
        font.pixelSize: Theme.fontPixelSize
        font.family: Theme.fontFamily
        color: Theme.peach
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: process
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var s = text.trim()
                var muted = s.indexOf("MUTED") >= 0
                var m = s.match(/[\d.]+/)
                var vol = m ? parseFloat(m[0]) : 0
                var pct = Math.round(vol * 100)
                label.text = (muted ? "\uF6A9   " : "\uF028   ") + pct + "%"
                label.color = muted ? Theme.overlay0 : Theme.peach
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

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton)
                Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
            else
                Quickshell.execDetached(["pavucontrol"])
            process.running = false
            process.running = true
        }
    }

    Component.onCompleted: process.running = true
}
