# mango-layout

A Noctalia bar widget that opens a panel for switching [Mango](https://github.com/mangowm/mango) window manager layouts.

## Requirements

- [`mango`](https://github.com/mangowm/mango) — window manager
- [`jq`](https://jqlang.org) — JSON processor (used to parse active monitor layout)

## Usage

Click the bar widget to open the layout switcher panel. The current active layout is highlighted automatically. Click any layout button to apply it instantly.


## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `compactLabel` | `bool` | `false` | Displays the compact layout symbol in the panel instead of the full name. |
| `closeOnSelect` | `bool` | `false` | Closes the panel automatically after a layout is selected. |

## IPC

```sh
noctalia msg plugin yogaeru/mango-layout:bar focused open #open the layout picker panel
```