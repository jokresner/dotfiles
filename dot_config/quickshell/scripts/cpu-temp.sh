#!/usr/bin/env bash

set -u

read_temp() {
    local sensor=$1
    [ -n "$sensor" ] || return 1
    [ -f "$sensor" ] || return 1
    awk '{print int(($1 + 500) / 1000)}' "$sensor" 2>/dev/null
}

pick_sensor() {
    local d name f label_file label
    local sensor=""
    local cpu_like=""
    local k10=""
    local any=""

    for d in /sys/class/hwmon/hwmon* /sys/devices/platform/coretemp.0/hwmon/hwmon*; do
        [ -f "$d/name" ] || continue
        name=$(<"$d/name")

        for f in "$d"/temp*_input; do
            [ -f "$f" ] || continue
            [ -n "$any" ] || any="$f"

            label_file=${f%_input}_label
            label=""
            [ -f "$label_file" ] && label=$(<"$label_file")

            case "$label" in
                Package\ id*|Tdie*|SoC\ Temperature*)
                    printf '%s\n' "$f"
                    return 0
                    ;;
            esac

            case "$label" in
                *[Cc][Pp][Uu]*)
                    [ -n "$cpu_like" ] || cpu_like="$f"
                    ;;
            esac

            case "$name" in
                *cpu*|*CPU*)
                    [ -n "$cpu_like" ] || cpu_like="$f"
                    ;;
                k10temp)
                    [ -n "$k10" ] || k10="$f"
                    ;;
            esac
        done
    done

    sensor=${cpu_like:-${k10:-$any}}
    if [ -n "$sensor" ]; then
        printf '%s\n' "$sensor"
        return 0
    fi

    for d in /sys/class/thermal/thermal_zone*; do
        [ -f "$d/temp" ] || continue
        printf '%s\n' "$d/temp"
        return 0
    done

    return 1
}

main() {
    local sensor=${1:-}

    if [ -n "$sensor" ]; then
        read_temp "$sensor"
        return
    fi

    sensor=$(pick_sensor) || exit 0
    read_temp "$sensor"
}

main "$@"
