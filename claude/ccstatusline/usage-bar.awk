# Colored usage bar for ccstatusline (session / weekly), as a custom-command widget.
# Renders  ▓▓▓▓▓▓▓░░░ 72.0%  colored by threshold.
#
# Data source, in order:
#   1) stdin Claude Code JSON: rate_limits.<window>.used_percentage
#   2) fallback ~/.cache/ccstatusline/usage.json: <cacheKey>
#      (kept fresh by the native reset-timer widgets, which also need usageData)
#
# Args (-v):
#   key   : "session" (default) | "weekly" | "opus" | "sonnet" (per-model weekly)
#           | "context" (context window fill %, computed from stdin tokens/size)
#   label : optional prefix text
#   width : bar cells (default 10)
#   th    : 4 comma-separated pct thresholds "g,y,o,r" (default 50,75,90,100)
#   Color: <g green | <y yellow | <o orange | <r red+bold | >=r dark red+bold

BEGIN { RS = "\034" }   # slurp stdin into a single record ($0)

# First number following "k" inside string s, or -1 if absent.
function num(s, k,   p, rest) {
    p = index(s, "\"" k "\"")
    if (p == 0) return -1
    rest = substr(s, p + length(k) + 2)
    if (match(rest, /-?[0-9]+(\.[0-9]+)?/)) return substr(rest, RSTART, RLENGTH) + 0
    return -1
}

{
    if (key   == "")  key = "session"
    if (width + 0 == 0) width = 10
    n = split(th, T, ","); if (n < 4) { T[1]=50; T[2]=75; T[3]=90; T[4]=100 }

    if (key == "context") {
        # Same value as the native context-percentage widget:
        # context_window.used_percentage, else tokens / context_window_size.
        a = index($0, "\"context_window\"")
        if (a > 0) {
            blk = substr($0, a)
            r = index(blk, "\"rate_limits\"")     # bound: keep only the context_window region
            if (r > 0) blk = substr(blk, 1, r - 1)
            v = num(blk, "used_percentage")
            if (v < 0) {                          # compute fill % from tokens
                it = num(blk, "input_tokens")
                cc = num(blk, "cache_creation_input_tokens"); if (cc < 0) cc = 0
                cr = num(blk, "cache_read_input_tokens");     if (cr < 0) cr = 0
                cu = num(blk, "current_usage")
                tok = (it >= 0) ? it + cc + cr : (cu >= 0 ? cu : -1)
                sz  = num(blk, "context_window_size")
                if (tok >= 0 && sz > 0) v = tok / sz * 100
            }
        } else {
            v = -1
        }
    } else {
        if      (key == "weekly") { anchor = "seven_day";        ck = "weeklyUsage" }
        else if (key == "opus")   { anchor = "seven_day_opus";   ck = "weeklyOpusUsage" }
        else if (key == "sonnet") { anchor = "seven_day_sonnet"; ck = "weeklySonnetUsage" }
        else                      { anchor = "five_hour";        ck = "sessionUsage" }

        # 1) stdin rate_limits.<anchor>.used_percentage
        v = -1
        a = index($0, "\"" anchor "\"")
        if (a > 0) {
            rest = substr($0, a + length(anchor) + 2)   # text after the "anchor" key
            if (rest !~ /^[ ]*:[ ]*null/)               # null value -> fall through to cache
                v = num(rest, "used_percentage")
        }

        # 2) fallback to the usage cache file
        if (v < 0) {
            cache = ENVIRON["HOME"] "/.cache/ccstatusline/usage.json"
            buf = ""
            while ((getline line < cache) > 0) buf = buf line
            close(cache)
            v = num(buf, ck)
        }
    }

    if (v < 0) exit
    if (v < 0)   v = 0
    if (v > 100) v = 100

    filled = int(v / 100 * width + 0.5)
    bar = ""
    for (i = 0; i < width; i++) bar = bar (i < filled ? "▓" : "░")

    bold = ""
    if      (v < T[1]) c = "\033[32m"                       # green
    else if (v < T[2]) c = "\033[33m"                       # yellow
    else if (v < T[3]) c = "\033[38;5;208m"                 # orange
    else if (v < T[4]) { c = "\033[31m";      bold = "\033[1m" }  # red, bold
    else               { c = "\033[38;5;88m"; bold = "\033[1m" }  # dark red, bold

    printf "%s%s%s%s %.1f%%\033[0m", bold, c, label, bar, v
}
