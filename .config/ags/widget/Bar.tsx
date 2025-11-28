import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import { createState, For } from "ags"
import Gio from "gi://Gio"
import GLib from "gi://GLib"

// System tray widget using StatusNotifierWatcher
function SystemTray() {
    const [trayItems, setTrayItems] = createState<Array<{id: string, busName: string, objectPath: string, icon: string, tooltip: string}>>([])
    
    const bus = Gio.DBus.session
    const watcherName = "org.kde.StatusNotifierWatcher"
    const watcherPath = "/StatusNotifierWatcher"
    
    const parseService = (service: string): { busName: string, objectPath: string } | null => {
        // Service format: either "busName/objectPath" or just "busName" (with default path)
        if (service.includes("/")) {
            const idx = service.indexOf("/")
            return {
                busName: service.substring(0, idx),
                objectPath: service.substring(idx)
            }
        }
        // Default StatusNotifierItem path
        return { busName: service, objectPath: "/StatusNotifierItem" }
    }
    
    const fetchTrayItem = (service: string) => {
        const parsed = parseService(service)
        if (!parsed) return
        
        const { busName, objectPath } = parsed
        
        // Use org.freedesktop.DBus.Properties.Get to fetch IconName
        bus.call(
            busName,
            objectPath,
            "org.freedesktop.DBus.Properties",
            "Get",
            new GLib.Variant("(ss)", ["org.kde.StatusNotifierItem", "IconName"]),
            GLib.VariantType.new("(v)"),
            Gio.DBusCallFlags.NONE,
            -1,
            null,
            (source: Gio.DBusConnection | null, res: Gio.AsyncResult) => {
                let iconName = "application-x-executable"
                let tooltip = busName
                
                try {
                    if (source) {
                        const result = source.call_finish(res)
                        const variant = result.get_child_value(0).get_variant()
                        if (variant) {
                            iconName = variant.get_string()[0] || iconName
                        }
                    }
                } catch (e) {
                    // Fallback icon already set
                }
                
                // Fetch tooltip/title
                bus.call(
                    busName,
                    objectPath,
                    "org.freedesktop.DBus.Properties",
                    "Get",
                    new GLib.Variant("(ss)", ["org.kde.StatusNotifierItem", "Title"]),
                    GLib.VariantType.new("(v)"),
                    Gio.DBusCallFlags.NONE,
                    -1,
                    null,
                    (src: Gio.DBusConnection | null, titleRes: Gio.AsyncResult) => {
                        try {
                            if (src) {
                                const titleResult = src.call_finish(titleRes)
                                const titleVariant = titleResult.get_child_value(0).get_variant()
                                if (titleVariant) {
                                    tooltip = titleVariant.get_string()[0] || tooltip
                                }
                            }
                        } catch (e) {
                            // Use fallback tooltip
                        }
                        
                        setTrayItems((items) => {
                            // Avoid duplicates
                            if (items.some(i => i.id === service)) return items
                            return [...items, { id: service, busName, objectPath, icon: iconName, tooltip }]
                        })
                    }
                )
            }
        )
    }
    
    const removeTrayItem = (service: string) => {
        setTrayItems((items) => items.filter(i => i.id !== service))
    }
    
    const loadExistingItems = () => {
        bus.call(
            watcherName,
            watcherPath,
            "org.freedesktop.DBus.Properties",
            "Get",
            new GLib.Variant("(ss)", [watcherName, "RegisteredStatusNotifierItems"]),
            GLib.VariantType.new("(v)"),
            Gio.DBusCallFlags.NONE,
            -1,
            null,
            (source: Gio.DBusConnection | null, res: Gio.AsyncResult) => {
                try {
                    if (!source) return
                    const result = source.call_finish(res)
                    const variant = result.get_child_value(0).get_variant()
                    if (variant) {
                        const items = variant.deep_unpack() as string[]
                        items.forEach(fetchTrayItem)
                    }
                } catch (e) {
                    // No items or watcher not running
                }
            }
        )
    }
    
    const setupWatcher = () => {
        // Listen for new items
        bus.signal_subscribe(
            watcherName,
            watcherName,
            "StatusNotifierItemRegistered",
            watcherPath,
            null,
            Gio.DBusSignalFlags.NONE,
            (_conn, _sender, _path, _iface, _signal, params) => {
                if (!params) return
                const [service] = params.deep_unpack() as [string]
                fetchTrayItem(service)
            }
        )
        
        // Listen for removed items
        bus.signal_subscribe(
            watcherName,
            watcherName,
            "StatusNotifierItemUnregistered",
            watcherPath,
            null,
            Gio.DBusSignalFlags.NONE,
            (_conn, _sender, _path, _iface, _signal, params) => {
                if (!params) return
                const [service] = params.deep_unpack() as [string]
                removeTrayItem(service)
            }
        )
        
        loadExistingItems()
    }
    
    setTimeout(() => setupWatcher(), 500)
    
    const activateItem = (item: {busName: string, objectPath: string}) => {
        bus.call(
            item.busName,
            item.objectPath,
            "org.kde.StatusNotifierItem",
            "Activate",
            new GLib.Variant("(ii)", [0, 0]),
            null,
            Gio.DBusCallFlags.NONE,
            -1,
            null,
            null
        )
    }
    
    return (
        <box orientation={Gtk.Orientation.HORIZONTAL} spacing={4} cssName="system-tray">
            <For each={trayItems}>
                {(item) => (
                    <button 
                        class="tray-icon" 
                        tooltipText={item.tooltip}
                        onClicked={() => activateItem(item)}
                    >
                        <image iconName={item.icon} pixelSize={16} />
                    </button>
                )}
            </For>
        </box>
    )
}

// Pacman updates
function PacmanUpdates() {
    const updates = createPoll("0", 30000, async () => {
        try {
            const result = await execAsync(["sh", "-c", "checkupdates 2>/dev/null | wc -l"])
            return result.trim() || "0"
        } catch {
            return "0"
        }
    })

    return (
        <button
            class="bar-button pacman-btn"
            tooltipText="Package updates"
        >
            <box orientation={Gtk.Orientation.HORIZONTAL} spacing={5}>
                <label label="󰅢" class="icon" />
                <label label={updates} class="value" />
            </box>
        </button>
    )
}

// Workspaces with persistent 1-5
function Workspaces() {
    const workspaceText = createPoll("● ○ ○ ○ ○", 300, async () => {
        try {
            const activeResult = await execAsync(["hyprctl", "activeworkspace", "-j"])
            const active = JSON.parse(activeResult)
            const allResult = await execAsync(["hyprctl", "workspaces", "-j"])
            const allWorkspaces = JSON.parse(allResult)
            
            const occupiedIds = new Set(
                allWorkspaces.filter((w: any) => w.windows > 0).map((w: any) => w.id)
            )
            
            return [1, 2, 3, 4, 5].map(id => {
                if (id === active.id) return "●"  // active
                if (occupiedIds.has(id)) return "○"  // occupied
                return "◦"  // empty
            }).join(" ")
        } catch {
            return "● ○ ○ ○ ○"
        }
    })

    return (
        <box class="workspaces" orientation={Gtk.Orientation.HORIZONTAL} spacing={4}>
            <button
                class="workspace-btn"
                onClicked={() => execAsync(["hyprctl", "dispatch", "workspace", "1"])}
                tooltipText="Workspace 1"
            >
                <label label={workspaceText} class="workspace-dots" />
            </button>
        </box>
    )
}

// CPU usage
function CpuUsage() {
    const cpuUsage = createPoll("0%", 2000, async () => {
        try {
            const result = await execAsync([
                "sh", "-c",
                "grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}'"
            ])
            return `${parseFloat(result.trim() || "0").toFixed(0)}%`
        } catch {
            return "0%"
        }
    })

    return (
        <box class="bar-module cpu" orientation={Gtk.Orientation.HORIZONTAL} spacing={5}>
            <label label="󰻠" class="icon" />
            <label label={cpuUsage} class="value" />
        </box>
    )
}

// Memory usage
function MemoryUsage() {
    const memUsage = createPoll("0/0GB", 2000, async () => {
        try {
            const result = await execAsync([
                "sh", "-c",
                "free -b | grep Mem | awk '{printf \"%.1f/%.0fGB\", $3/1024/1024/1024, $2/1024/1024/1024}'"
            ])
            return result.trim()
        } catch {
            return "0/0GB"
        }
    })

    return (
        <box class="bar-module memory" orientation={Gtk.Orientation.HORIZONTAL} spacing={5}>
            <label label="󰍛" class="icon" />
            <label label={memUsage} class="value" />
        </box>
    )
}

// Temperature
function Temperature() {
    const [available, setAvailable] = createState(true)
    
    const temp = createPoll("0°C", 3000, async () => {
        // AMD Ryzen: prefer Tccd1 (actual die temp) over Tctl (control temp with offset)
        try {
            const result = await execAsync(["sh", "-c", 
                "sensors k10temp-pci-00c3 2>/dev/null | grep -E 'Tccd1|Tdie' | head -1 | grep -oE '\\+[0-9]+\\.[0-9]+' | tr -d '+'"
            ])
            const t = result.trim()
            if (t && !isNaN(parseFloat(t)) && parseFloat(t) > 0) {
                setAvailable(true)
                return `${Math.round(parseFloat(t))}°C`
            }
        } catch { }

        // Fallback to Tctl or Intel coretemp
        try {
            const result = await execAsync(["sh", "-c", 
                "sensors 2>/dev/null | grep -E 'Tctl|Package id 0|Core 0' | head -1 | grep -oE '\\+[0-9]+\\.[0-9]+' | head -1 | tr -d '+'"
            ])
            const t = result.trim()
            if (t && !isNaN(parseFloat(t)) && parseFloat(t) > 0) {
                setAvailable(true)
                return `${Math.round(parseFloat(t))}°C`
            }
        } catch { }

        setAvailable(false)
        return ""
    })

    return (
        <box class="bar-module temperature" orientation={Gtk.Orientation.HORIZONTAL} spacing={5} visible={available}>
            <label label="󰔏" class="icon" />
            <label label={temp} class="value" />
        </box>
    )
}

// Bluetooth
function Bluetooth() {
    const [available, setAvailable] = createState(false)
    
    // Check if bluetooth controller exists
    execAsync(["sh", "-c", "bluetoothctl show 2>/dev/null"])
        .then(r => setAvailable(r.trim().length > 0))
        .catch(() => setAvailable(false))

    const icon = createPoll("󰂲", 5000, async () => {
        try {
            const powered = await execAsync(["sh", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered: yes'"])
            if (!powered.trim()) return "󰂲"

            const connected = await execAsync(["sh", "-c", "bluetoothctl devices Connected 2>/dev/null"])
            if (connected.trim()) return "󰂯"
            return "󰂯"
        } catch {
            return "󰂲"
        }
    })

    return (
        <button
            class="bar-button bluetooth"
            tooltipText="Bluetooth"
            onClicked={() => execAsync(["blueman-manager"])}
            visible={available}
        >
            <label label={icon} class="icon" />
        </button>
    )
}

// Network
function Network() {
    const iconName = createPoll("network-wireless-symbolic", 5000, async () => {
        try {
            // Check WiFi
            const wifi = await execAsync(["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | head -1"])
            if (wifi.trim()) {
                const signal = parseInt(wifi.split(":")[2] || "0")
                if (signal >= 80) return "network-wireless-signal-excellent-symbolic"
                if (signal >= 60) return "network-wireless-signal-good-symbolic"
                if (signal >= 40) return "network-wireless-signal-ok-symbolic"
                return "network-wireless-signal-weak-symbolic"
            }

            // Check Ethernet
            const eth = await execAsync(["sh", "-c", "nmcli -t -f type,state dev | grep 'ethernet:connected'"])
            if (eth.trim()) return "network-wired-symbolic"

            return "network-offline-symbolic"
        } catch {
            return "network-offline-symbolic"
        }
    })

    return (
        <button
            class="bar-button network"
            tooltipText="Network"
            onClicked={() => execAsync(["ghostty", "-e", "nmtui"])}
        >
            <image iconName={iconName} pixelSize={16} />
        </button>
    )
}

// Battery
function Battery() {
    const [available, setAvailable] = createState(false)
    
    // Check if battery exists on startup
    execAsync(["sh", "-c", "ls /sys/class/power_supply/BAT* 2>/dev/null"])
        .then(r => setAvailable(r.trim().length > 0))
        .catch(() => setAvailable(false))

    const percent = createPoll("", 30000, async () => {
        try {
            const capacity = await execAsync(["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1"])
            const p = parseInt(capacity.trim()) || 0
            return `${p}%`
        } catch {
            return ""
        }
    })

    const icon = createPoll("󰁹", 30000, async () => {
        try {
            const capacity = await execAsync(["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1"])
            const charging = await execAsync(["sh", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"])
            
            const p = parseInt(capacity.trim()) || 0
            const isCharging = charging.trim().toLowerCase() === "charging"

            if (isCharging) return "󰂄"
            if (p <= 10) return "󰁻"
            if (p <= 30) return "󰁼"
            if (p <= 50) return "󰁾"
            if (p <= 70) return "󰂀"
            if (p <= 90) return "󰂂"
            return "󰁹"
        } catch {
            return ""
        }
    })

    return (
        <box class="bar-module battery" orientation={Gtk.Orientation.HORIZONTAL} spacing={5} tooltipText="Battery" visible={available}>
            <label label={percent} class="value" />
            <label label={icon} class="icon" />
        </box>
    )
}

// Clock
function Clock() {
    const time = createPoll("00:00:00", 1000, async () => {
        const result = await execAsync(["date", "+%H:%M:%S"]).catch(() => "00:00:00")
        return result.trim() || "00:00:00"
    })

    return (
        <box class="bar-module clock" orientation={Gtk.Orientation.HORIZONTAL} spacing={5}>
            <label label={time} class="value" />
            <label label="" class="icon" />
        </box>
    )
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP } = Astal.WindowAnchor
    const monitorWidth = gdkmonitor.geometry.width
    const barWidth = Math.floor(monitorWidth * 0.99)

    return (
        <window
            visible
            name="bar"
            class="Bar"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={TOP}
            application={app}
            widthRequest={barWidth}
        >
            <centerbox cssName="centerbox" orientation={Gtk.Orientation.HORIZONTAL}>
                {/* Left: notification, clock, pacman, tray */}
                <box $type="start" class="left-modules" orientation={Gtk.Orientation.HORIZONTAL} spacing={8}>
                    <Clock />
                    <PacmanUpdates />
                    <SystemTray />
                </box>

                {/* Center: Workspaces */}
                <box $type="center" class="center-modules" orientation={Gtk.Orientation.HORIZONTAL}>
                    <Workspaces />
                </box>

                {/* Right: cpu, memory, temperature, bluetooth, network, battery */}
                <box $type="end" class="right-modules" orientation={Gtk.Orientation.HORIZONTAL} spacing={8}>
                    <CpuUsage />
                    <MemoryUsage />
                    <Temperature />
                    <Bluetooth />
                    <Network />
                    <Battery />
                </box>
            </centerbox>
        </window>
    )
}
