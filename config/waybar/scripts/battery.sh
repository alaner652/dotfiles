#!/usr/bin/env bash

# ---------- 工具 ----------
get_val() {
  local path=$1
  [ -f "$path" ] && cat "$path" || echo 0
}

get_energy() {
  local bat=$1

  now=$(get_val /sys/class/power_supply/$bat/energy_now)
  full=$(get_val /sys/class/power_supply/$bat/energy_full)

  # fallback
  if [ "$now" -eq 0 ]; then
    now=$(get_val /sys/class/power_supply/$bat/charge_now)
    full=$(get_val /sys/class/power_supply/$bat/charge_full)
  fi

  echo "$now $full"
}

# ---------- 讀電池 ----------
read now0 full0 <<< $(get_energy BAT0)
read now1 full1 <<< $(get_energy BAT1)

total_now=$((now0 + now1))
total_full=$((full0 + full1))

if [ "$total_full" -gt 0 ]; then
  percentage=$((100 * total_now / total_full))
else
  percentage=0
fi

# ---------- 判斷是否插電 ----------
plugged=0
for src in /sys/class/power_supply/*; do
  if [ -f "$src/online" ]; then
    val=$(cat "$src/online")
    if [ "$val" -eq 1 ]; then
      plugged=1
      break
    fi
  fi
done

# ---------- icon ----------
if [ "$percentage" -ge 80 ]; then icon=""
elif [ "$percentage" -ge 60 ]; then icon=""
elif [ "$percentage" -ge 40 ]; then icon=""
elif [ "$percentage" -ge 20 ]; then icon=""
else icon=""
fi

# ---------- text ----------
if [ "$plugged" -eq 1 ]; then
  text=" ${percentage}%"
else
  text="${icon} ${percentage}%"
fi

# ---------- tooltip ----------
status0=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
status1=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)

tooltip="BAT0: $status0\nBAT1: $status1\nTotal: ${percentage}%"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
