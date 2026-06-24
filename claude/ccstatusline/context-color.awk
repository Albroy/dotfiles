# Standalone : no jq, no wrapper. Wired into ccstatusline as a custom-command widget:

BEGIN { RS = "\034" }   # slurp the whole input into a single record ($0)

# Return the first number following "key" in the JSON, or -1 if absent.
function num(key,   p, rest) {
    p = index($0, "\"" key "\"")
    if (p == 0) return -1
    rest = substr($0, p + length(key) + 2)
    if (match(rest, /-?[0-9]+(\.[0-9]+)?/)) return substr(rest, RSTART, RLENGTH) + 0
    return -1
}

{
    it = num("input_tokens")
    if (it >= 0) {                              # current_usage is an object
        cc = num("cache_creation_input_tokens"); if (cc < 0) cc = 0
        cr = num("cache_read_input_tokens");     if (cr < 0) cr = 0
        t = it + cc + cr
    } else {
        cu = num("current_usage")               # current_usage is a number
        if (cu >= 0) {
            t = cu
        } else {                                # fall back to percentage * window
            pct = num("used_percentage"); sz = num("context_window_size")
            if (pct >= 0 && sz > 0) t = pct / 100 * sz
            else exit
        }
    }

    if (t <= 0) exit

    bold = ""
    if      (t < 50000)  c = "\033[32m"                       # green
    else if (t < 100000) c = "\033[33m"                       # yellow
    else if (t < 160000) c = "\033[38;5;208m"                 # orange
    else if (t < 300000) { c = "\033[31m";       bold = "\033[1m" }  # red, bold
    else                 { c = "\033[38;5;88m";  bold = "\033[1m" }  # dark red, bold

    if      (t >= 1000000) label = sprintf("%.1fM", t / 1000000)
    else if (t >= 1000)    label = sprintf("%.1fk", t / 1000)
    else                   label = sprintf("%d", t)

    printf "%s%s%s\033[0m", bold, c, label
}
