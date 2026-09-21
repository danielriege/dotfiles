#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: tmux_setup.sh [-v|--vibe] [-a|--agent claude|codex|ozzy] [path-to-repo]

Create a window in the current tmux session:
  Full layout: lazygit / nvim on the left, agent / shell on the right.
  -v, --vibe:  lazygit on the left, agent on the right (defaults to $PWD).
  No path:     home layout in the current window (spotify, btop, shell, agent).

The agent defaults to claude; set TMUX_SETUP_AGENT to change the default.
Use the repo's .venv, then the main checkout's .venv for a linked worktree.
If neither has .venv/bin/activate, leave the shell environment as it is.

Options may appear before or after the path. Use -- before a path starting
with a dash. -h / --help shows this help.
EOF
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

set_target() {
    [[ -z "$TARGET" ]] || die "unexpected extra argument '$1'."
    [[ -n "$1" ]] || die "the repo path cannot be empty."
    TARGET="$1"
}

find_venv() {
    VENV=""
    if [[ -f "$REPO/.venv/bin/activate" ]]; then
        VENV="$REPO/.venv/bin/activate"
        return
    fi

    # Git lists the main checkout first. NUL-delimited fields preserve paths
    # containing spaces or quotes. A bare repository has no main checkout.
    local field main_repo=""
    while IFS= read -r -d '' field; do
        case "$field" in
            'worktree '*) main_repo="${field#worktree }" ;;
            bare) main_repo="" ;;
            '') break ;;
        esac
    done < <(git -C "$REPO" worktree list --porcelain -z 2>/dev/null)

    if [[ -n "$main_repo" && "$main_repo" != "$REPO" && -f "$main_repo/.venv/bin/activate" ]]; then
        VENV="$main_repo/.venv/bin/activate"
    fi
}

send_command() {
    # Send command text literally, then submit it as a separate keystroke.
    tmux send-keys -t "$1" -l -- "$2"
    tmux send-keys -t "$1" Enter
}

VIBE=0
TARGET=""
AGENT="${TMUX_SETUP_AGENT:-claude}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--vibe)
            VIBE=1
            shift
            ;;
        -a|--agent)
            [[ $# -ge 2 ]] || die "$1 requires claude, codex, or ozzy."
            AGENT="$2"
            shift 2
            ;;
        --agent=*)
            AGENT="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            for target in "$@"; do
                set_target "$target"
            done
            break
            ;;
        -*) die "unknown option '$1'; see --help." ;;
        *)
            set_target "$1"
            shift
            ;;
    esac
done

case "$AGENT" in
    claude|codex) AGENT_COMMAND="$AGENT"; AGENT_BINARY="$AGENT" ;;
    ozzy)
        SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
        [[ -x "$SCRIPT_DIR/ozzy-claude.sh" ]] || die "ozzy-claude.sh must be installed alongside tmux_setup.sh."
        printf -v AGENT_COMMAND '%q' "$SCRIPT_DIR/ozzy-claude.sh"
        AGENT_BINARY=claude
        ;;
    *) die "unknown agent '$AGENT'; choose claude, codex, or ozzy." ;;
esac

command -v tmux >/dev/null 2>&1 || die "tmux is not on PATH."
[[ -n "${TMUX:-}" ]] || die "not inside a tmux session."
command -v "$AGENT_BINARY" >/dev/null 2>&1 || die "$AGENT_BINARY is not on PATH."

if [[ $VIBE -eq 0 && -z "$TARGET" ]]; then
    # Home layout: spotify | btop above shell | agent, all split evenly.
    tmux rename-window home
    ORIG=$(tmux display-message -p '#{pane_id}')
    BOT_L=$(tmux split-window -v -l '50%' -t "$ORIG" -c "$HOME" -P -F '#{pane_id}')
    BOT_R=$(tmux split-window -h -l '50%' -t "$BOT_L" -c "$HOME" -P -F '#{pane_id}')
    TOP_R=$(tmux split-window -h -l '50%' -t "$ORIG" -c "$HOME" -P -F '#{pane_id}')

    send_command "$ORIG" spotify
    send_command "$TOP_R" btop
    send_command "$BOT_L" clear
    send_command "$BOT_R" "clear && $AGENT_COMMAND"
    tmux select-pane -t "$ORIG"
    exit 0
fi

TARGET="${TARGET:-$PWD}"
[[ -d "$TARGET" ]] || die "'$TARGET' is not a directory."
REPO="$(CDPATH= cd -- "$TARGET" && pwd -P)"
# Accept a directory within a checkout as well as its root. Plain project
# directories also work; Git simply supplies no worktree fallback for them.
if REPO_ROOT=$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null); then
    REPO="$REPO_ROOT"
fi
WIN="${REPO##*/}"

find_venv
PANE_COMMAND=clear
if [[ -n "$VENV" ]]; then
    printf -v QUOTED_VENV '%q' "$VENV"
    PANE_COMMAND="source $QUOTED_VENV && clear"
fi

# Stable pane IDs survive the index changes caused by subsequent splits.
# The right column takes 40% in both project layouts.
LEFT_TOP=$(tmux new-window -n "$WIN" -c "$REPO" -P -F '#{pane_id}')
RIGHT_TOP=$(tmux split-window -h -l '40%' -t "$LEFT_TOP" -c "$REPO" -P -F '#{pane_id}')

if [[ $VIBE -eq 1 ]]; then
    send_command "$LEFT_TOP" "$PANE_COMMAND && lazygit"
    send_command "$RIGHT_TOP" "$PANE_COMMAND && $AGENT_COMMAND"
else
    RIGHT_BOT=$(tmux split-window -v -l '50%' -t "$RIGHT_TOP" -c "$REPO" -P -F '#{pane_id}')
    LEFT_BOT=$(tmux split-window -v -l '50%' -t "$LEFT_TOP" -c "$REPO" -P -F '#{pane_id}')

    send_command "$LEFT_TOP" "$PANE_COMMAND && lazygit"
    send_command "$LEFT_BOT" "$PANE_COMMAND && nvim"
    send_command "$RIGHT_TOP" "$PANE_COMMAND && $AGENT_COMMAND"
    send_command "$RIGHT_BOT" "$PANE_COMMAND"
fi

tmux select-pane -t "$LEFT_TOP"
