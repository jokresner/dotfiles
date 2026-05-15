//@ pragma UseQApplication
//@ pragma Env QT_QPA_PLATFORM=wayland
import QtQuick
import Quickshell
import qs.Bar
import qs.Widgets

ShellRoot {
    id: root
    property var barInstances: []
    Component {
        id: barComponent
        Bar {}
    }
    function updateBars() {
        for (var i = 0; i < barInstances.length; i++)
            barInstances[i].destroy()
        barInstances = []
        var screens = Quickshell.screens
        if (screens.length === 0) {
            var bar = barComponent.createObject(root, {})
            if (bar) barInstances.push(bar)
        } else {
            for (var i = 0; i < screens.length; i++) {
                var bar = barComponent.createObject(root, { screen: screens[i] })
                if (bar) barInstances.push(bar)
            }
        }
    }
    ThemeSwitcherWindow {}
    WallpaperSwitcherWindow {}

    Component.onCompleted: {
        Quickshell.watchFiles = true
        Qt.callLater(updateBars)
    }
    Connections {
        target: Quickshell
        function onScreensChanged() { updateBars() }
    }
}
