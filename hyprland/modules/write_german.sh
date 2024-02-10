
case "$1" in
    a)
        wl-copy ä
        wtype -s 300 -M ctrl -P v
        ;;
    A)
        wl-copy Ä
        wtype -s 300 -M ctrl -P v
        ;;
    o)
        wl-copy ö
        wtype -s 300 -M ctrl -P v
        ;;
    O)
        wl-copy Ö
        wtype -s 300 -M ctrl -P v
        ;;
    u)
        wl-copy ü
        wtype -s 300 -M ctrl -P v
        ;;
    U)
        wl-copy Ü
        wtype -s 300 -M ctrl -P v
        ;;
    s)
        wl-copy ß
        wtype -s 300 -M ctrl -P v
        ;;

    *)
        ;;
esac
