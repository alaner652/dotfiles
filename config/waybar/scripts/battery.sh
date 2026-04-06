#!/usr/bin/env bash

# 讀取電量
bat0=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
bat1=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)

# 預設用 BAT1（外接）
main=${bat1:-$bat0}

# 狀態
status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)

# icon 判斷
if [ "$main" -ge 80 ]; then icon=""
elif [ "$main" -ge 60 ]; then icon=""
elif [ "$main" -ge 40 ]; then icon=""
elif [ "$main" -ge 20 ]; then icon=""
else icon=""
fi

# 文字（充電判斷）
if [ "$status" = "Charging" ]; then
  text=" ${main}%"
else
  text="${icon} ${main}%"
fi

# tooltip（雙電池）
tooltip="BAT0: ${bat0}%\nBAT1: ${bat1}%"

# JSON 輸出（Waybar 需要）
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
