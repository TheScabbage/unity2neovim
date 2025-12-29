#!/usr/bin/env bash
echo "Running nvim attachment script..."
# This is similar to the unity2neovim script, but it uses neovide as a frontend and provides automatic focus switching.
# If no relevant editor is found, a new neovide instance will be created.
# Its servername will be located in the /Temp/ directory of the Unity project.

# Dependencies
# - `neovim-remote`
# - `wmctrl` (for focus-switching)
# - `neovide` (as a convenient GUI nvim wrapper)

USER_ID=$(id -u)
RUN_PATH="/run/user/$USER_ID/"
LOGFILE="~/unity-to-nvim-log.txt"

SELECTED_INSTANCE=""

if [ $# -lt 2 ]; then
    echo "Not enough arguments provided. Usage: open_in_nvim.sh [file] [line]"
fi

TARGET_FILE=$1
TARGET_LINE=$2

# touch $LOGFILE

echo "Attempting to open Unity file '$1' at line '$2' in nvim..." # >> "$LOGFILE"

UNITY_DIR=$(echo $TARGET_FILE | sed 's|/Assets/.*||')

# Check the project directory for an nvim server started via this script:
INSTANCE_PATH="$UNITY_DIR/Temp/nvim-addr"

echo "Checking if instance is at $INSTANCE_PATH"
if [ -e $INSTANCE_PATH ]; then
    CWD=$(nvr --servername $INSTANCE_PATH --remote-expr "getcwd()")
    echo "Found instance in project directory. CWD: $CWD"

    # check if nvr command failed
    if [ $? -ne 0 ]; then
        echo "Couldn't get CWD of instance at $ADDR"
    else
        # check if nvr couldnt read from the address
        if [[ "$CWD" == *"!"* ]]; then
            echo "Couldn't get CWD of instance at $ADDR" #| tee $LOGFILE
        else
            # check if target file has the CWD as a prefix,
            # if so, this is probably the best instance
            if [[ $TARGET_FILE =~ $CWD* ]]; then
                echo "Selecting instance $INSTANCE_PATH as the CWD ($CWD) matches the target file ($TARGET_FILE)"
                SELECTED_INSTANCE=$INSTANCE_PATH
            else
                echo "CWD of local project didnt match! bruh"
            fi
        fi
    fi
else
    echo "No servername at $INSTANCE_PATH. Searching default location..."
    while read ADDR; do
        echo "Instance found at $ADDR"
        INSTANCE_PATH="$RUN_PATH$ADDR"
        CWD=$(nvr --servername $INSTANCE_PATH --remote-expr "getcwd()")

        echo "CWD: $CWD"
        # check if nvr command failed
        if [ $? -ne 0 ]; then
            echo "Couldn't get CWD of instance at $ADDR" # | tee $LOGFILE
            continue;
        fi

        # check if nvr couldnt read from the address
        if [[ "$CWD" == *"!"* ]]; then
            echo "Couldn't get CWD of instance at $ADDR" # | tee $LOGFILE
            continue;
        fi

        # check if target file has the CWD as a prefix,
        # if so, this is probably the best instance
        if [[ $TARGET_FILE =~ $CWD* ]]; then
            echo "Selecting instance $INSTANCE_PATH as the CWD ($CWD) matches the target file ($TARGET_FILE)"
            SELECTED_INSTANCE=$INSTANCE_PATH
        fi
    done < <(ls $RUN_PATH | grep nvim)
fi

echo "Currently selected instance: '$SELECTED_INSTANCE'"

if [[ $SELECTED_INSTANCE == "" ]]; then
    echo "Couldnt find instance. Opening a new one..." # | tee >> $LOGFILE
    # Open Neovide in project directory
    SELECTED_INSTANCE="$UNITY_DIR/Temp/nvim-addr"
    echo "Opening new instance at '$UNITY_DIR' with server name at '$SELECTED_INSTANCE'" # | tee $LOGFILE
    neovide $UNITY_DIR -- --listen "$SELECTED_INSTANCE" &
    sleep 0.1
    nvr --servername $SELECTED_INSTANCE --nostart -c "cd $UNITY_DIR"
else
    echo "Found instance at $SELECTED_INSTANCE" # | tee $LOGFILE
fi

echo "Telling instance to open file '$TARGET_FILE'. Server Name: '$SELECTED_INSTANCE'"
nvr --servername $SELECTED_INSTANCE --nostart -c "e $TARGET_FILE"
nvr --servername $SELECTED_INSTANCE --nostart -c "$TARGET_LINE"
nvr --servername $SELECTED_INSTANCE --nostart -c "normal! zz"

# Focus the app.
# I always have neovide on desktop 1, so use `wmctrl` to switch to it:
wmctrl -s 1
