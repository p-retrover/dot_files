# Fonts for terminal

To get special glyphs of themes like oh-my-posh working, download nerd fonts.
In linux systems install them and place in the `/usr/share/fonts/TTF` folder.

To see the install fonts run

```bash
fc-list # to get full list
fc-list | grep -i "<any partial font name>" # to get list of specific names
```

To set font in integrated terminals like vscode, make sure that in the settings, the terminal font is set to one of the available nerd fonts.

In vscode open the settings ( `ctrl + ,`), then search `terminal.integrated.fontfamily`
and there set one of the available fonts.
