#!/usr/bin/env bash
# tmux "C-b j" analog: pick a window living on another workspace and pull it
# into the current workspace, then focus it.

cur=$(hyprctl activeworkspace -j | jq -r '.id')

label_expr='"[ws \(.workspace.id)] \(.class) — \(.title)"'

mapfile -t lines < <(hyprctl clients -j \
  | jq -r --argjson cur "$cur" \
    ".[] | select(.workspace.id != \$cur and .mapped) | $label_expr")

[ ${#lines[@]} -eq 0 ] && { notify-send -t 1500 "Join window" "No window on another workspace"; exit 0; }

choice=$(printf '%s\n' "${lines[@]}" | rofi -dmenu -i -p "Join window")
[ -z "$choice" ] && exit 0

addr=$(hyprctl clients -j \
  | jq -r --arg c "$choice" ".[] | select($label_expr == \$c) | .address" \
  | head -1)
[ -z "$addr" ] && exit 0

hyprctl dispatch movetoworkspacesilent "$cur,address:$addr"
hyprctl dispatch focuswindow "address:$addr"
