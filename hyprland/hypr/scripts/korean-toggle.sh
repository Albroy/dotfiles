#!/usr/bin/env bash
# Standard Dubeolsik expects QWERTY keysyms,

VIRT="hl-virtual-keyboard-fcitx5"
REF="at-translated-set-2-keyboard"   # physical laptop keyboard, drives direction

keymap=$(hyprctl -j devices | jq -r --arg k "$REF" \
    '.keyboards[] | select(.name==$k) | .active_keymap')

if [[ "$keymap" == *French* ]]; then
    target=1                       # -> us (QWERTY)
    fcitx5-remote -o               # activate hangul
    notify-send -t 1500 "입력: 한국어" "us + hangul"
else
    target=0                       # -> fr (AZERTY)
    fcitx5-remote -c              
    notify-send -t 1500 "Saisie : Français" "fr"
fi

hyprctl -j devices \
    | jq -r --arg v "$VIRT" '.keyboards[] | select(.name != $v) | .name' \
    | while read -r kbd; do
        hyprctl switchxkblayout "$kbd" "$target" >/dev/null 2>&1
    done
