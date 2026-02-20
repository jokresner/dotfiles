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
            width: 20
            height: 20
            color: model.isActive ? Theme.accentColor : (model.isOccupied ? "#555" : "#333")
            border.color: model.isUrgent ? "red" : "#777"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: model.tagId
                color: "white"
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
