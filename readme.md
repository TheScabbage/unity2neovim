# Unity2Neovim

Scripts for linking Unity stacktraces and console logs to a running neovim instance.

# Installation
Place the shell script somewhere handy.

Go into Unity:
Edit > Preferences > External Tools

Set `External Script Editor` to the `open_in_nvim.sh` script.

Set `External Script Editor Args` to:
```
$(File) $(Line) $(Column)
```

When double-clicking logs in the console, that file will be opened in
any existing neovim editor that has the current working directory (`echo getcwd()`)
set to the relevant Unity project.

