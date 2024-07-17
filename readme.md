# Unity2Neovim

This script links Unity stacktraces and console logs to a neovim instance.
Loads up a Neovide wrapper around new instances, but this could easily be
changed to a terminal emulator running regular neovim.

# Dependencies
- `neovim-remote`
- `wmctrl` (for focus-switching)
- `neovide` (as a convenient GUI nvim wrapper)

# Installation
Place the shell script somewhere handy.

Go into Unity:
Edit > Preferences > External Tools

Set `External Script Editor` to the `open_in_nvim.sh` script.

Set `External Script Editor Args` to:
```
$(File) $(Line)
```

When double-clicking logs in the console, that file will be opened in
any existing neovim editor that has the current working directory (`echo getcwd()`)
set to the relevant Unity project.

If no relevant editor is found, a new neovide instance will be created.
Its servername will be located in the /Temp/ directory of the Unity project.
