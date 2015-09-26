# bash-fancy-ps1

Modifies your current `$PS1` to replace `\w` with a shorter string.  Also affects `$PROMPT_COMMAND`.  Put `bash-fancy-ps1` somewhere in your path, like `~/bin/`, then add this to your `~/.bashrc`:

```sh
if [ -n "$TERM" -a "$TERM" != "dumb" ]; then
    if which bash-fancy-ps1.sh >/dev/null 2>&1; then
        source $(which bash-fancy-ps1.sh)

        # Try to make CWD 30 characters.  Also see FANCYPS1_DYNAMIC.
        # Default:
        #FANCYPS1_CWDLENGTH=30

        # When not 0, try to make CWD this percentage of the width of
        # your terminal
        # Default:
        #FANCYPS1_DYNAMIC=0

        # The string to fill your path with when elements are removed
        # Default: (depends on if you are UTF-8 or not)
        #FANCYPS1_FILL="$(echo -ne '\u2736')" # 2736 = ✷  279d = ➝  2026 = …
        #FANCYPS1_FILL="..."
    fi
fi
```
