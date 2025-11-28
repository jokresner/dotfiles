import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"

export default function LogoutMenu() {
    const handleAction = async (action: string) => {
        const menuWindow = app.get_window("logout-menu")
        if (menuWindow) {
            menuWindow.hide()
        }

        try {
            switch (action) {
                case "lock":
                    await execAsync(["hyprlock"]).catch(() => 
                        execAsync(["swaylock"]).catch(() => 
                            execAsync(["loginctl", "lock-session"])
                        )
                    )
                    break
                case "logout":
                    await execAsync(["hyprctl", "dispatch", "exit"]).catch(() =>
                        execAsync(["swaymsg", "exit"]).catch(() =>
                            execAsync(["loginctl", "terminate-user", "$USER"])
                        )
                    )
                    break
                case "reboot":
                    await execAsync(["systemctl", "reboot"]).catch(() =>
                        execAsync(["reboot"])
                    )
                    break
                case "shutdown":
                    await execAsync(["systemctl", "poweroff"]).catch(() =>
                        execAsync(["poweroff"])
                    )
                    break
            }
        } catch (error) {
            console.error(`Failed to execute ${action}:`, error)
        }
    }

    return (
        <window
            name="logout-menu"
            class="LogoutMenu"
            visible={false}
            application={app}
            exclusivity={Astal.Exclusivity.NORMAL}
            keymode={Astal.Keymode.ON_DEMAND}
            layer={Astal.Layer.OVERLAY}
        >
            <Gtk.EventControllerKey
                onKeyPressed={({ widget }, keyval: number) => {
                    if (keyval === Gdk.KEY_Escape) {
                        widget.hide()
                    }
                }}
            />
            <box class="logout-menu-container" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
                <box class="logout-menu-header" orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
                    <label label="󰐥" class="logout-header-icon" />
                    <label label="Power Menu" class="logout-header-label" />
                </box>
                <box class="logout-menu-content" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
                    <button 
                        class="logout-menu-item"
                        onClicked={() => handleAction("lock")}
                    >
                        <box class="menu-item-content" orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
                            <label label="🔒" class="menu-icon" />
                            <label label="Lock" class="menu-label" />
                        </box>
                    </button>
                    <button 
                        class="logout-menu-item"
                        onClicked={() => handleAction("logout")}
                    >
                        <box class="menu-item-content" orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
                            <label label="🚪" class="menu-icon" />
                            <label label="Logout" class="menu-label" />
                        </box>
                    </button>
                    <button 
                        class="logout-menu-item"
                        onClicked={() => handleAction("reboot")}
                    >
                        <box class="menu-item-content" orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
                            <label label="🔄" class="menu-icon" />
                            <label label="Reboot" class="menu-label" />
                        </box>
                    </button>
                    <button 
                        class="logout-menu-item logout-menu-item-danger"
                        onClicked={() => handleAction("shutdown")}
                    >
                        <box class="menu-item-content" orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
                            <label label="⏻" class="menu-icon" />
                            <label label="Shutdown" class="menu-label" />
                        </box>
                    </button>
                </box>
            </box>
        </window>
    )
}

