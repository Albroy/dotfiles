# tmux — sessions, windows, panes

The tmux hierarchy and how our binds (`tmux.conf`) manipulate it.
Prefix = `C-b` everywhere.

## The hierarchy

```
tmux server
└── session            ← a workspace (≈ one attached "screen")
    └── window         ← a full-screen tab inside the session
        └── pane       ← a split of the window, 1 pty = 1 shell
```

- **session**: what a client attaches to. You detach/reattach a whole session.
  List: `tmux ls`.
- **window**: a tab. A window can belong to **several sessions at once** (see
  *links* below) — it is the unit of **sharing**.
- **pane**: a split inside a window. A pane lives in exactly **one** window. No
  shared or linked pane: it only exists in its window.

### Key rule: sharing granularity = the window

| Object  | Shareable across sessions? | Mechanism        |
|---------|----------------------------|------------------|
| session | —                          | —                |
| window  | **yes**, live on both ends | `link-window`    |
| pane    | **no**                     | moved only       |

A linked window is the **same object** seen in N sessions: same content, live
input everywhere. A pane can only be **moved** between windows
(`join-pane` / `break-pane`) — never duplicated nor shared.

## Custom binds (`tmux.conf`)

### Chords `j` / `u`

`j` = **JOIN/attach**, `u` = **UNLINK/detach**. Never deletes.

```
bind j switch-client -T joinmode      # C-b j  → arms the joinmode table
bind u switch-client -T detachmode    # C-b u  → arms the detachmode table
```

`switch-client -T <table>` does not change session: it says *"look up the next
key in this table"*. This is tmux's native mechanism for multi-key shortcuts
(chords). After one key, it auto-returns to the root table.

| Chord     | Action                                                        | tmux command         |
|-----------|---------------------------------------------------------------|----------------------|
| `C-b j w` | link a window from another session **into** this one          | `link-window -s`     |
| `C-b j p` | pull a pane from anywhere → split to the **right** of current | `join-pane -h -s`    |
| `C-b u w` | unlink the current window from this session                   | `unlink-window`      |

The fzf binds go through **fzf** (`fzf-tmux`) to pick the target, and `xargs -r`
so nothing runs when cancelled (Esc) — otherwise the `xargs … returned 123` error.

To break a pane out into its own window, use the native **`C-b !`** — we don't
bind a `C-b u p` since it would just duplicate it.

### Other binds

| Bind      | Action                                                        |
|-----------|---------------------------------------------------------------|
| `C-b f`   | switch session via fzf (content preview)                      |
| `C-b y`   | toggle `synchronize-panes`: input to **all** panes of the window, **red** background (`colour52`) while ON |
| `C-b r`   | reload bashrc (`send-keys "reload"`)                          |

## Raw command cheatsheet

```sh
tmux ls                         # sessions
tmux lsw                        # windows of the current session
tmux lsw -a                     # all windows, all sessions
tmux lsp                        # panes of the current window
tmux lsp -a                     # all panes
tmux link-window   -s SRC -t DST   # link (share) a window
tmux unlink-window -t WIN          # unlink
tmux join-pane  -h -s SRC [-t DST] # move a pane into a split
tmux break-pane -d -s PANE         # extract a pane into a window
```

IDs: session `#S`, window `#{window_id}`/`#I`, pane `#{pane_id}` (`%N`, stable
even after a move).
