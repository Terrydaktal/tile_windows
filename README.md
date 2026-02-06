# tile_windows

`tile_windows` is a bash script that automatically tiles open windows on your Linux desktop. It is designed to be efficient, respect existing row placement, and honor desktop workareas (including panels).

## Features

- **Smart Tiling**: Automatically arranges windows into a grid based on the specified number of rows.
- **Row-Preserving Tiling**: Assigns each window to the closest row based on its current position, then tiles within that row left-to-right.
- **Titlebar Management**: Includes a helper script `titlebars` to force windows into a borderless state via KWin rules, ensuring perfect alignment.
- **WM_CLASS Matching**: Target specific applications by matching their `WM_CLASS` string (e.g., `xfce4-terminal`, `code`, `google-chrome`).
- **Workarea Awareness**: Automatically detects the usable screen area, accounting for panels and bars (with specific support for `xfce4-panel`).
- **Configurable Gaps**: Includes a fixed gap between windows for a cleaner look.
- **Multi-Monitor Support**: Basic support for screen geometry via `xdotool` or `xdpyinfo`.

## Prerequisites

The following tools must be installed and available in your `PATH`:

- `bash`: The script shell.
- `python3`: Used for the row assignment and KWin rule editing.
- `wmctrl`: For window management (removing decorations, etc.).
- `xdotool`: For window resizing, moving, and desktop geometry.
- `xprop`: For gathering window properties.
- `xwininfo`: For retrieving window geometry.
- `xdpyinfo`: For fallback screen dimension detection.
- `qdbus` (or `qdbus6`): Required by `titlebars` to notify KWin of configuration changes.

On Debian/Ubuntu-based systems, you can install the dependencies with:

```bash
sudo apt-get install wmctrl xdotool x11-utils python3
```

## Usage

### 1. Preparing Windows (KDE/KWin)

For the best experience (and to ensure window positioning is pixel-perfect), it is highly recommended to remove window decorations (titlebars and borders) before tiling. The included `titlebars` script manages KWin rules to automate this.

**Why run this first?**
`tile_windows` calculates positions based on client geometry. If windows have titlebars, KWin may offset the window to accommodate the decoration, or the tiled grid may overlap/misalign. Removing decorations ensures that the window occupies exactly the space calculated by the tiling script.

```bash
# Add a borderless rule for the active window
./titlebars add --active

# Or match by a pattern (e.g., all terminals)
./titlebars add --match xfce4-terminal
```
*Note: After adding a rule, you may need to restart the application or use `./titlebars remove <pattern>` to toggle it.*

### 2. Tiling Windows

Once decorations are removed, run the tiling script:

```bash
./tile_windows [rows] [wm_class_substrings]
```

- **rows**: (Optional) The number of rows in the tiling grid. Defaults to `1`.
- **wm_class_substrings**: (Optional) A comma-separated list of case-insensitive substrings to match against window `WM_CLASS` (logical OR). Defaults to `xfce4-terminal` when omitted.
  - Pass an explicit empty string (`""`) to match **all** visible windows.
  - Desktop/panel/dock windows (e.g. Plasma desktop/panels) are always excluded.

### Examples

Tile all terminal windows into 2 rows:
```bash
./tile_windows 2 xfce4-terminal
```

Tile all VS Code windows into a single row:
```bash
./tile_windows 1 code
```

Tile Firefox and xfce4-terminal together:
```bash
./tile_windows 2 firefox,xfce4-terminal
```

Tile all visible windows on the current desktop:
```bash
./tile_windows 2 ""
```

## How it Works

1. **Discovery**: Finds all visible windows on the current desktop matching the provided `WM_CLASS` substring(s).
2. **Row Calculation**: Splits the workarea into `rows` horizontal bands.
3. **Assignment**: Assigns each window to the closest row by vertical position, then orders windows left-to-right within each row.
4. **Execution**: Resizes and moves each window to its row tile.

## License

This project is open-source and available under the [MIT License](LICENSE).
