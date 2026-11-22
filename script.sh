for loc in C.UTF-8 en_US.UTF-8 es_MX.UTF-8; do
    if LC_ALL=$loc true 2>/dev/null; then export LC_ALL=$loc; break; fi
done

TEAL=$'\e[36m'
WHITE=$'\e[1;37m'
YELLOW=$'\e[1;33m'
RESET=$'\e[0m'
if [[ ! -t 1 || -n ${NO_COLOR:-} ]]; then TEAL='' WHITE='' YELLOW='' RESET=''; fi

center() {
    local t=$1 w=$2 l
    l=$(( (w - ${#t}) / 2 ))
    printf '%*s%s%*s' "$l" '' "$t" $((w - ${#t} - l)) ''
}
row() { printf '| |%-26s| |' "$1"; }

shield() {
    local title=$1 m1=$2 m2=$3 r
    shift 3
    SHIELD=(
        " ______________________________ "
        "|$(center "$title" 30)|"
        "| .--------------------------. |"
    )
    for r in "$@"; do SHIELD+=("$(row "$r")"); done
    SHIELD+=(
        "| '--------------------------' |"
        "|$(center "$m1" 30)|"
        " \\$(center "$m2" 28)/ "
        "  \\$(center '' 26)/  "
        "   '-.$(center '' 20).-'   "
        "      '--..__________..--'      "
    )
}

shield "UNIVERSIDAD AUTONOMA DE QRO" "EDUCO EN LA VERDAD" "Y EN EL HONOR" \
    '  _o_       \ | /       /' \
    ' (/|\)    -- (*) --   /' \
    '  /_\_      / | \   /' \
    ' (@) |\           /' \
    '     |_|        /' \
    '              /   .-o-.' \
    '            /    ( (@) )' \
    "          /    o  '-+-'" \
    '        /          o' \
    '      /' \
    '    /' \
    '  /'
LEFT=("${SHIELD[@]}")

shield "FACULTAD DE INFORMATICA" "RAZONAMIENTO Y TECNOLOGIA" "PARA INNOVAR Y TRASCENDER" \
    '  _o_               /0/0/' \
    ' (/|\)_           /0/0/' \
    '  /_\[]         /1/1/' \
    ' /   \        /1/1/  .-o.' \
    '            /1/1/   ( @ )' \
    '          /1/1/  .------.' \
    '        /1/1/    | [>]  |' \
    '      /1/1/  _   |  []  |' \
    "    /1/1/  _( )_ '------'" \
    '  /1/1/  (_   _)/____\' \
    '/1/1/     |_|' \
    '/1/'
RIGHT=("${SHIELD[@]}")

print_logos() {
    local i
    echo
    for i in "${!LEFT[@]}"; do
        printf '  %s%-32s%s    %s%s%s\n' "$TEAL" "${LEFT[$i]}" "$RESET" "$TEAL" "${RIGHT[$i]}" "$RESET"
    done
    echo
}

last_update_epoch() {
    local f
    for f in /var/lib/apt/periodic/update-success-stamp /var/lib/apt/lists /var/cache/apt/pkgcache.bin /var/log/apt/history.log; do
        if [[ -e $f ]]; then
            stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null
            return
        fi
    done
}

days_since_update() {
    local ts
    ts=$(last_update_epoch)
    if [[ -z $ts ]]; then
        echo "desconocido"
    else
        echo $(( ($(date +%s) - ts) / 86400 ))
    fi
}

print_box() {
    local line plain width=0 pad
    for line in "$@"; do
        plain=${line%%|*}
        (( ${#plain} > width )) && width=${#plain}
    done
    local bar
    bar=$(printf '%*s' $((width + 2)) '' | sed 's/ /─/g')
    printf '  %s┌%s┐%s\n' "$WHITE" "$bar" "$RESET"
    for line in "$@"; do
        plain=${line%%|*}
        pad=$((width - ${#plain}))
        printf '  %s│%s %s%*s %s│%s\n' "$WHITE" "$RESET" "${line#*|}" "$pad" '' "$WHITE" "$RESET"
    done
    printf '  %s└%s┘%s\n' "$WHITE" "$bar" "$RESET"
    echo
}

main() {
    local days cmd label1 label2
    days=$(days_since_update)
    cmd='sudo apt update && sudo apt upgrade'
    label1="Días desde la última actualización: "
    label2="Para actualizar el servidor ejecuta el siguiente comando:"

    print_logos
    print_box \
        "${label1}${days}|${label1}${YELLOW}${days}${RESET}" \
        "|" \
        "${label2}|${label2}" \
        "  ${cmd}|  ${YELLOW}${cmd}${RESET}"
}

main "$@"
