import QtQuick
import Quickshell.Io
import qs.Theme

Row {
    id: root
    spacing: Theme.spacing

    property ListModel workspaces: ListModel {}

    Process {
        id: workspaceProcess
        running: true
        command: ["mmsg", "-w"]

        stdout: SplitParser {
            onRead: line => {
                parseWorkspaceLine(line);
            }
        }
    }

    function parseWorkspaceLine(line) {
        const tagBinary = /^(\S+)\s+tags\s+([01]+)\s+([01]+)\s+([01]+)$/
        const match = line.match(tagBinary);

        if (match) {
            const outputName = match[1];
            const occ = match[2];
            const sel = match[3];
            const urg = match[4];

            workspaces.clear();

            for (let i = 0; i < occ.length; i++) {
                const tagId = i + 1;
                const charIdx = occ.length - 1 - i;

                const isOccupied = occ[charIdx] === '1';
                const isActive = sel[charIdx] === '1';
                const isUrgent = urg[charIdx] === '1';

                workspaces.append({
                    "tagId": tagId,
                    "output": outputName,
                    "isOccupied": isOccupied,
                    "isActive": isActive,
                    "isUrgent": isUrgent
                });
            }
        }
    }

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
                    Quickshell.execDetached(["mmsg", "-s", "-t", model.tagId]);
                }
            }
        }
    }
}
