import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Widgets

PanelWindow {
    id: panel
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.barHeight + Theme.barMargin * 2
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: implicitHeight
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.barMargin
        anchors.rightMargin: Theme.barMargin
        anchors.topMargin: Theme.barMargin
        anchors.bottomMargin: Theme.barMargin
        spacing: Theme.spacing

        BarPill {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            WorkspaceWidget {}
            NetTrafficWidget {}
        }

        Item { Layout.fillWidth: true }

        BarPill {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Clock { panelWindow: panel }
        }

        Item { Layout.fillWidth: true }

        BarPill {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            StorageWidget {}
            MemoryWidget {}
            CpuWidget {}
            TemperatureWidget {}
            AudioWidget {}
            TrayWidget { panelWindow: panel }
        }
    }
}
