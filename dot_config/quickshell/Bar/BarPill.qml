import QtQuick
import QtQuick.Layouts
import qs.Theme

Item {
    id: root
    default property alias content: sectionContent.data
    property real pillRadius: Theme.sectionRadius
    property real pillPadding: Theme.sectionPadding

    implicitWidth: sectionContent.implicitWidth + pillPadding * 2
    implicitHeight: Theme.barHeight - 2

    Rectangle {
        anchors.fill: parent
        radius: pillRadius
        color: Theme.base
        opacity: 0.6
    }

    RowLayout {
        id: sectionContent
        anchors.centerIn: parent
        spacing: Theme.widgetSpacing
        height: parent.height - 2
    }
}
