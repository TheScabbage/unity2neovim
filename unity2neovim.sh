#!/usr/bin/env bash
# This script can be used to click on Unity error logs and open them in a running neovim instance.
# It searches /run/user/$UID/ for any neovim sockets that are open in the project directory.
# The first nvim instance to be found will be sent to the file/line/column of the error.
# If no neovim instances are open, then this script is a no-op.

# To use this, open "Edit > Preferences > External Tools" in Unity.
# Set "External Script Editor" to this script.
# Set "External Script Editor Args" to "$(File) $(Line) $(Column)"

FILE="$1"
LINE="$2"
COLUMN="$3"

# Unity runs this from the project directory
PROJECT_DIR="$(pwd -P)"

# Find nvim instances and check their working directory
for socket in ${XDG_RUNTIME_DIR:-/run/user/$UID}/nvim.*.0; do
    [ -S "$socket" ] || continue

    # Check if this nvim instance is in the project
    CWD=$(nvim --headless --server "$socket" --remote-expr 'getcwd()' 2>/dev/null)

    if [[ "$CWD" == "$PROJECT_DIR"* ]]; then
        nvim --headless --server "$socket" --remote-send "<ESC>:e $FILE<CR>:$LINE<CR>$COLUMN|"

        # Focus the terminal.
        # I always have ghostty on desktop 0, so use `wmctrl` to switch to it:
        wmctrl -s 0

        exit 0
    fi
done


echo "No neovim instance found in project '$PROJECT_DIR'"
