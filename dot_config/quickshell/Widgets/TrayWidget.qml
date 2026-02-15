import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Theme

Item {
    id: root
    property var panelWindow: null
    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    RowLayout {
        id: trayRow
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            delegate: Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: icon
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: modelData.icon || ""
                    sourceSize: Qt.size(width, height)
                    smooth: true
                    mipmap: true
                    visible: !!modelData.icon
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton)
                            modelData.activate()
                        else if (mouse.button === Qt.RightButton && root.panelWindow) {
                            var p = ma.mapToItem(root.panelWindow.contentItem, mouse.x, mouse.y)
                            modelData.display(root.panelWindow, p.x, p.y)
                        } else if (mouse.button === Qt.MiddleButton)
                            modelData.secondaryActivate()
                    }
                    onWheel: function(wheel) {
                        modelData.scroll(wheel.angleDelta.y, false)
                    }
                }
            }
        }
    }
}
