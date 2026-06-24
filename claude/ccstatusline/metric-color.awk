# Generic ccstatusline metric colorizer.
# Reads Claude Code statusline JSON on stdin, prints a value colored by threshold.
#
# Args (-v):
#   key   : JSON key to read. Special value "context" = composite context-length
#           tokens (input + cache_creation + cache_read, with fallbacks).
#           Otherwise = first number following that key anywhere in the JSON.
#   unit  : "tokens" (default, k/M formatting) | "pct" (percentage, "%")
#   label : optional prefix text (default none)
#   th    : 4 comma-separated thresholds "g,y,o,r". Defaults per unit:
#             tokens -> 50000,100000,160000,300000
#             pct    -> 50,75,90,100
#   Color rule: <g green | <y yellow | <o orange | <r red+bold | >=r dark red+bold

BEGIN {
    RS = "\034"                          # slurp whole input into $0
    if (key  == "") key  = "context"
    if (unit == "") unit = "tokens"
    n = split(th, T, ",")
    if (n < 4) {
        if (unit == "pct") { T[1]=50;    T[2]=75;     T[3]=90;     T[4]=100    }
        else               { T[1]=50000; T[2]=100000; T[3]=160000; T[4]=300000 }
    }
}

# First number following "key" in the JSON, or -1 if absent.
function num(k,   p, rest) {
    p = index($0, "\"" k "\"")
    if (p == 0) return -1
    rest = substr($0, p + length(k) + 2)
    if (match(rest, /-?[0-9]+(\.[0-9]+)?/)) return substr(rest, RSTART, RLENGTH) + 0
    return -1
}

{
    if (key == "context") {
        it = num("input_tokens")
        if (it >= 0) {                              # current_usage is an object
            cc = num("cache_creation_input_tokens"); if (cc < 0) cc = 0
            cr = num("cache_read_input_tokens");     if (cr < 0) cr = 0
            v = it + cc + cr
        } else {
            cu = num("current_usage")               # current_usage is a number
            if (cu >= 0) {
                v = cu
            } else {                                # fall back to percentage * window
                p = num("used_percentage"); s = num("context_window_size")
                if (p >= 0 && s > 0) v = p / 100 * s
                else exit
            }
        }
    } else {
        v = num(key)
        if (v < 0) exit
    }

    if (v <= 0) exit

    bold = ""
    if      (v < T[1]) c = "\033[32m"                       # green
    else if (v < T[2]) c = "\033[33m"                       # yellow
    else if (v < T[3]) c = "\033[38;5;208m"                 # orange
    else if (v < T[4]) { c = "\033[31m";       bold = "\033[1m" }  # red, bold
    else               { c = "\033[38;5;88m";  bold = "\033[1m" }  # dark red, bold

    if      (unit == "pct")  val = sprintf("%.0f%%", v)
    else if (v >= 1000000)   val = sprintf("%.1fM", v / 1000000)
    else if (v >= 1000)      val = sprintf("%.1fk", v / 1000)
    else                     val = sprintf("%d", v)

    printf "%s%s%s%s\033[0m", bold, c, label, val
}
