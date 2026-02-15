//@ pragma UseQApplication
//@ pragma Env QT_QPA_PLATFORM=wayland
import QtQuick
import Quickshell
import qs.Bar

ShellRoot {
    id: root
    Component.onCompleted: Quickshell.watchFiles = true
    Bar {}
}
