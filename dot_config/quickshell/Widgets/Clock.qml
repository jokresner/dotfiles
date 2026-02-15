import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme

Item {
    id: clockRoot
    property bool popupOpen: false
    property var panelWindow: null
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        text: "\uF017   " + Qt.formatDateTime(new Date(), "HH:mm  d MMM")
        font.pixelSize: Theme.fontPixelSize
        font.family: Theme.fontFamily
        color: Theme.mauve
        verticalAlignment: Text.AlignVCenter
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: label.text = "\uF017   " + Qt.formatDateTime(new Date(), "HH:mm  d MMM")
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: clockRoot.popupOpen = !clockRoot.popupOpen
    }

    PopupWindow {
        id: popup
        visible: clockRoot.popupOpen
        implicitWidth: 280
        implicitHeight: 320
        anchor.item: clockRoot
        anchor.rect: Qt.rect(0, clockRoot.height, clockRoot.width, 1)
        anchor.edges: Qt.AlignTop | Qt.AlignLeft
        anchor.gravity: Qt.AlignBottom | Qt.AlignRight

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.85)
            border.color: Theme.surface1
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                // Header: close only
                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "×"
                        font.pixelSize: Theme.fontPixelSize + 4
                        font.family: Theme.fontFamily
                        color: Theme.subtext0
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            onClicked: clockRoot.popupOpen = false
                        }
                    }
                }

                // Month navigation
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: 4
                    Text {
                        text: "‹"
                        font.pixelSize: Theme.fontPixelSize + 2
                        font.family: Theme.fontFamily
                        color: Theme.subtext0
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: calendar.prevMonth()
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDate(calendar.viewDate, "MMMM yyyy")
                        font.pixelSize: Theme.fontPixelSize + 1
                        font.family: Theme.fontFamily
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: "›"
                        font.pixelSize: Theme.fontPixelSize + 2
                        font.family: Theme.fontFamily
                        color: Theme.subtext0
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: calendar.nextMonth()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Today"
                        font.pixelSize: Theme.fontPixelSize - 2
                        font.family: Theme.fontFamily
                        color: Theme.sky
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            onClicked: {
                                calendar.viewDate = new Date()
                                calendar.refresh()
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
                // Day names (Mon–Sun)
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["M", "T", "W", "T", "F", "S", "S"]
                        Text {
                            Layout.preferredWidth: 32
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData
                            font.pixelSize: Theme.fontPixelSize - 2
                            font.family: Theme.fontFamily
                            color: Theme.overlay0
                        }
                    }
                }

                // Calendar grid
                GridLayout {
                    id: calGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 2
                    Repeater {
                        model: calendar.daysModel
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignHCenter
                            color: modelData.isToday ? Theme.surface1 : "transparent"
                            radius: 4
                            border.color: modelData.isToday ? Theme.mauve : "transparent"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData.day > 0 ? modelData.day : ""
                                font.pixelSize: Theme.fontPixelSize - 1
                                font.family: Theme.fontFamily
                                color: modelData.isCurrentMonth ? Theme.text : Theme.overlay0
                            }
                        }
                    }
                }
            }
        }
    }

    QtObject {
        id: calendar
        property date viewDate: new Date()
        property var daysModel: []

        function refresh() {
            var d = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1)
            var year = d.getFullYear(), month = d.getMonth()
            var firstWeekday = (d.getDay() + 6) % 7 // Mon=0
            var daysInMonth = new Date(year, month + 1, 0).getDate()
            var today = new Date()
            var todayDate = today.getDate()
            var todayMonth = today.getMonth()
            var todayYear = today.getFullYear()
            var list = []
            var i
            for (i = 0; i < firstWeekday; i++)
                list.push({ day: 0, isToday: false, isCurrentMonth: false })
            for (i = 1; i <= daysInMonth; i++)
                list.push({
                    day: i,
                    isToday: i === todayDate && month === todayMonth && year === todayYear,
                    isCurrentMonth: true
                })
            var total = list.length
            var remainder = total % 7
            if (remainder) {
                for (i = 0; i < 7 - remainder; i++)
                    list.push({ day: 0, isToday: false, isCurrentMonth: false })
            }
            daysModel = list
        }

        function prevMonth() {
            viewDate = new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1)
            refresh()
        }
        function nextMonth() {
            viewDate = new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1)
            refresh()
        }

        Component.onCompleted: refresh()
        onViewDateChanged: refresh()
    }

    Connections {
        target: clockRoot
        function onPopupOpenChanged() {
            if (clockRoot.popupOpen)
                calendar.viewDate = new Date()
            calendar.refresh()
        }
    }
}
