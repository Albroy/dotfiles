#!/usr/bin/env bash
#   ____ _ _       _     _     _
#  / ___| (_)_ __ | |__ (_)___| |_
# | |   | | | '_ \| '_ \| / __| __|
# | |___| | | |_) | | | | \__ \ |_
#  \____|_|_| .__/|_| |_|_|___/\__|
#           |_|
#
# Gestionnaire de presse-papier (cliphist + rofi)
# usage: cliphist.sh        -> coller une entrée
#        cliphist.sh d      -> supprimer une entrée
#        cliphist.sh w      -> vider l'historique

case $1 in
    d)
        cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist delete
    ;;
    w)
        cliphist wipe
    ;;
    *)
        cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy
    ;;
esac
