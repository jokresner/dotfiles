import QtQuick
import Quickshell.Io
import qs.Theme

Row {
    id: root
    spacing: Theme.spacing

    property ListModel workspaces: ListModel {}

    Process {
        id: process
        command: ["sh", "-c", "hyprctl activeworkspace -j | jq .id; hyprctl workspaces -j | jq -c ."]
        running: false
        stdout: StdioCollector {
            onStreamFinished: function() {
                var lines = text.trim().split('\n');
                if (lines.length < 2) return;
                var activeId = parseInt(lines[0], 10);
                var workspacesData = JSON.parse(lines[1]);

                workspaces.clear();
                workspacesData.forEach(workspace => {
                    workspaces.append({
                        "tagId": workspace.id,
                        "output": workspace.monitor,
                        "isOccupied": workspace.windows > 0,
                        "isActive": workspace.id === activeId,
                        "isUrgent": false
                    });
                });
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 500
        repeat: false
        onTriggered: process.running = true
    }

    Component.onCompleted: process.running = true

    Repeater {
        model: workspaces
        delegate: Rectangle {
            height: Theme.barHeight - 16
            width: height
            radius: width / 2
            color: model.isActive ? Theme.mauve : (model.isOccupied ? Theme.surface1 : Theme.surface0)
            border.color: model.isUrgent ? Theme.red : "transparent"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: model.tagId
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Quickshell.execDetached(["hyprctl", "dispatch", "workspace", model.tagId]);
                }
            }
        }
    }
}
