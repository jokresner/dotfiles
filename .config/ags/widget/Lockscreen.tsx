import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

// Lock function to show all lockscreen windows
export function lock() {
    const monitors = app.get_monitors()
    monitors.forEach((_, i) => {
        const win = app.get_window(`lockscreen-${i}`)
        if (win) win.visible = true
    })
}

// Unlock function to hide all lockscreen windows
function unlock() {
    const monitors = app.get_monitors()
    monitors.forEach((_, i) => {
        const win = app.get_window(`lockscreen-${i}`)
        if (win) win.visible = false
    })
}

export default function Lockscreen(gdkmonitor: Gdk.Monitor, monitorIndex: number) {
    const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

    // Clock - only poll on primary (index 0) to avoid duplicate work
    const time = createPoll("00:00", 1000, async () => {
        const result = await execAsync(["date", "+%H:%M"]).catch(() => "00:00")
        return result.trim()
    })

    // Date
    const date = createPoll("", 60000, async () => {
        const result = await execAsync(["date", "+%A, %B %d"]).catch(() => "")
        return result.trim()
    })

    // Only show input on primary monitor
    const isPrimary = monitorIndex === 0

    // State references (only used on primary)
    let passwordEntry: Gtk.Entry | null = null
    let inputBox: Gtk.Box | null = null
    let hintLabel: Gtk.Label | null = null
    let lockIconLabel: Gtk.Label | null = null
    let isUnlocking = false

    const setError = (msg: string) => {
        if (inputBox) inputBox.add_css_class("error")
        if (hintLabel) hintLabel.label = msg
        if (lockIconLabel) lockIconLabel.label = "󰌿"
        
        setTimeout(() => {
            if (inputBox) inputBox.remove_css_class("error")
            if (hintLabel) hintLabel.label = "Press Enter to unlock"
        }, 2000)
    }

    const attemptUnlock = async () => {
        if (isUnlocking || !passwordEntry) return
        const pwd = passwordEntry.text
        if (!pwd) return

        isUnlocking = true
        if (hintLabel) hintLabel.label = "Authenticating..."
        if (lockIconLabel) lockIconLabel.label = "󰌾"

        try {
            const user = (await execAsync(["whoami"])).trim()
            
            // PAM authentication via pamtester
            await execAsync([
                "sh", "-c",
                `echo '${pwd.replace(/'/g, "'\\''")}' | pamtester login ${user} authenticate`
            ])

            // Success - hide all lockscreens
            if (passwordEntry) passwordEntry.text = ""
            if (hintLabel) hintLabel.label = "Press Enter to unlock"
            if (lockIconLabel) lockIconLabel.label = "󰌿"
            unlock()
        } catch {
            setError("Authentication failed")
            if (passwordEntry) passwordEntry.text = ""
        }

        isUnlocking = false
    }

    return (
        <window
            visible={false}
            name={`lockscreen-${monitorIndex}`}
            class="Lockscreen"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.IGNORE}
            anchor={TOP | BOTTOM | LEFT | RIGHT}
            keymode={isPrimary ? Astal.Keymode.EXCLUSIVE : Astal.Keymode.NONE}
            layer={Astal.Layer.OVERLAY}
            application={app}
        >
            {isPrimary && (
                <Gtk.EventControllerKey
                    onKeyPressed={({ widget }, keyval: number) => {
                        if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
                            attemptUnlock()
                            return true
                        }
                        return false
                    }}
                />
            )}
            <box
                orientation={Gtk.Orientation.VERTICAL}
                valign={Gtk.Align.CENTER}
                halign={Gtk.Align.CENTER}
                cssName="lockscreen-container"
                vexpand
                hexpand
            >
                {/* Time */}
                <label label={time} class="lock-time" />
                
                {/* Date */}
                <label label={date} class="lock-date" />
                
                {isPrimary ? (
                    <>
                        {/* Avatar */}
                        <box class="lock-avatar" halign={Gtk.Align.CENTER}>
                            <label label="󰀄" class="avatar-icon" />
                        </box>

                        {/* Password Input */}
                        <box 
                            class="lock-input-container"
                            orientation={Gtk.Orientation.HORIZONTAL}
                            halign={Gtk.Align.CENTER}
                            onRealize={(self: Gtk.Box) => { inputBox = self }}
                        >
                            <label 
                                label="󰌿" 
                                class="lock-icon"
                                onRealize={(self: Gtk.Label) => { lockIconLabel = self }}
                            />
                            <entry
                                class="lock-input"
                                placeholderText="Enter password..."
                                visibility={false}
                                hexpand
                                onRealize={(self: Gtk.Entry) => { passwordEntry = self }}
                                onActivate={() => attemptUnlock()}
                            />
                        </box>

                        {/* Hint */}
                        <label 
                            label="Press Enter to unlock" 
                            class="lock-hint"
                            onRealize={(self: Gtk.Label) => { hintLabel = self }}
                        />
                    </>
                ) : (
                    /* Secondary monitors just show lock icon */
                    <box class="lock-avatar" halign={Gtk.Align.CENTER}>
                        <label label="󰌾" class="avatar-icon" />
                    </box>
                )}
            </box>
        </window>
    )
}
