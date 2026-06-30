#!/usr/bin/env bash
# tmux "C-b u" analog: send the active window to a workspace you pick.
# Lists workspaces 1-10 (with a hint of how many windows each holds) + "empty".

counts=$(hyprctl workspaces -j | jq -r '.[] | "\(.id):\(.windows)"')

menu=""
for n in 1 2 3 4 5 6 7 8 9 10; do
  c=$(printf '%s\n' "$counts" | awk -F: -v n="$n" '$1==n{print $2}')
  menu+="$n   ($([ -n "$c" ] && echo "$c" || echo 0) win)\n"
done
menu+="empty   (next free)"

sel=$(printf '%b\n' "$menu" | rofi -dmenu -i -p "Send window to" | awk '{print $1}')
[ -z "$sel" ] && exit 0

# follow the window to its new workspace; drop the "silent" word if you'd
# rather stay put -> use movetoworkspacesilent instead.
hyprctl dispatch movetoworkspace "$sel"
