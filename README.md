# tile_windows

`tile_windows` is a bash script that automatically tiles open windows on your Linux desktop. It is designed to be efficient, minimize window movement, and respect desktop workareas (including panels).

## Features

- **Smart Tiling**: Automatically arranges windows into a grid based on the specified number of rows.
- **Minimum Movement**: Uses the Hungarian algorithm (via an embedded Python script) to assign windows to grid cells such that the total movement is minimized.
- **WM_CLASS Matching**: Target specific applications by matching their `WM_CLASS` string (e.g., `xfce4-terminal`, `code`, `google-chrome`).
- **Workarea Awareness**: Automatically detects the usable screen area, accounting for panels and bars (with specific support for `xfce4-panel`).
- **Configurable Gaps**: Includes a fixed gap between windows for a cleaner look.
- **Multi-Monitor Support**: Basic support for screen geometry via `xdotool` or `xdpyinfo`.

## Prerequisites

The following tools must be installed and available in your `PATH`:

- `bash`: The script shell.
- `python3`: Used for the optimal window-to-cell assignment logic.
- `wmctrl`: For window management (removing decorations, etc.).
- `xdotool`: For window resizing, moving, and desktop geometry.
- `xprop`: For gathering window properties.
- `xwininfo`: For retrieving window geometry.
- `xdpyinfo`: For fallback screen dimension detection.

On Debian/Ubuntu-based systems, you can install the dependencies with:

```bash
sudo apt-get install wmctrl xdotool x11-utils python3
```

## Usage

```bash
./tile_windows [rows] [wm_class_substring]
```

- **rows**: (Optional) The number of rows in the tiling grid. Defaults to `1`.
- **wm_class_substring**: (Optional) A case-insensitive substring to match against window `WM_CLASS`. Defaults to `xfce4-terminal`. Note that providing a value here **replaces** the default (it does not add to it).

### Examples

Tile all terminal windows into 2 rows:
```bash
./tile_windows 2 xfce4-terminal
```

Tile all VS Code windows into a single row:
```bash
./tile_windows 1 code
```

## How it Works

1. **Discovery**: Finds all visible windows on the current desktop matching the provided `WM_CLASS`.
2. **Grid Calculation**: Calculates a grid layout based on the number of rows and the total number of windows, fitting them into the detected workarea.
3. **Optimization**: Calculates the "cost" (squared distance) for every window to every grid cell and uses the Hungarian algorithm to find the global minimum cost assignment.
4. **Execution**: Resizes and moves each window to its assigned cell.

## License

This project is open-source and available under the [MIT License](LICENSE).
