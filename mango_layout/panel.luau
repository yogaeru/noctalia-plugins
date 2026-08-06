local layouts = {
    { sym = "T",  name = "tile",              label = "Tile",              glyph = "layout-sidebar" },
    { sym = "S",  name = "scroller",          label = "Scroller",          glyph = "carousel-horizontal" },
    { sym = "M",  name = "monocle",           label = "Monocle",           glyph = "square" },
    { sym = "G",  name = "grid",              label = "Grid",              glyph = "layout-grid" },
    { sym = "F",  name = "fair",              label = "Fair",              glyph = "layout-board-split" },
    { sym = "D",  name = "deck",              label = "Deck",              glyph = "layers-difference" },
    { sym = "DW", name = "dwindle",           label = "Dwindle",           glyph = "layout-2" },
    { sym = "CT", name = "center_tile",       label = "Center Tile",       glyph = "layout-distribute-vertical" },
    { sym = "VT", name = "vertical_tile",     label = "Vertical Tile",     glyph = "layout-rows" },
    { sym = "RT", name = "right_tile",        label = "Right Tile",        glyph = "layout-sidebar-right" },
    { sym = "VS", name = "vertical_scroller", label = "Vertical Scroller", glyph = "carousel-vertical" },
    { sym = "VG", name = "vertical_grid",     label = "Vertical Grid",     glyph = "grid-dots" },
    { sym = "VD", name = "vertical_deck",     label = "Vertical Deck",     glyph = "chart-funnel" },
    { sym = "VF", name = "vertical_fair",     label = "Vertical Fair",     glyph = "layout-board" },
}

local config = {}
local activeLayout = ""

local COLUMNS = 3
local GAP = 4

local function reloadConfig()
    config.closeOnSelect = noctalia.getConfig("closeOnSelect") == true
    config.compactLabel = noctalia.getConfig("compactLabel") == true
end

local function makeGrid(children)
    local rows = {}
    local row = {}

    for i, child in ipairs(children) do
        table.insert(row, child)

        if #row == COLUMNS or i == #children then
            while #row < COLUMNS do
                table.insert(row, ui.spacer({ flexGrow = 1 }))
            end

            table.insert(rows, ui.row({
                gap = GAP,
                align = "stretch",
            }, row))

            row = {}
        end
    end

    return ui.column({ gap = GAP }, rows)
end

local function buildButtons()
    local buttons = {}

    for index, layout in ipairs(layouts) do
        local selected = layout.sym == activeLayout

        table.insert(buttons,
            ui.column({
                gap = 4,
                align = "center",
                flexGrow = 1,
            }, {

                ui.button({
                    glyph = layout.glyph,
                    glyphSize = 28,
                    variant = selected and "primary" or "ghost",
                    onClick = "onPick" .. (index - 1),
                }),

                ui.label({
                    text = config.compactLabel and layout.sym or layout.label,
                    fontSize = 12,
                    fontWeight = "bold",
                    color = selected and "primary" or "on_surface_variant",
                    textAlign = "center",
                    maxLines = 1,
                }),

            })
        )
    end

    return buttons
end

local function render()
    panel.render(
        ui.column({}, {
            ui.scroll({
                flexGrow = 1,
            }, {
                ui.column({
                    padding = 12,
                    gap = GAP,
                }, {
                    makeGrid(buildButtons())
                })
            })
        })
    )
end

local function onPick(index)
    local layout = layouts[index + 1]

    if not layout then
        return
    end

    activeLayout = layout.sym

    noctalia.runAsync(
        string.format('mmsg dispatch "setlayout, %s"', layout.name)
    )

    if config.closeOnSelect then
        panel.close()
    else
        render()
    end
end

function onOpen()
    reloadConfig()

    noctalia.runAsync(
        [[mmsg get all-monitors | jq -r '.monitors[] | select(.active == true and .last_open_surface != null) | .layout_symbol']],
        function(result)
            if not result or result.exitCode ~= 0 then
                return
            end

            activeLayout = result.stdout:gsub("%s+", "")
            render()
        end
    )
end

function onConfigChanged()
    reloadConfig()
    render()
end

function onPick0()  onPick(0) end
function onPick1()  onPick(1) end
function onPick2()  onPick(2) end
function onPick3()  onPick(3) end
function onPick4()  onPick(4) end
function onPick5()  onPick(5) end
function onPick6()  onPick(6) end
function onPick7()  onPick(7) end
function onPick8()  onPick(8) end
function onPick9()  onPick(9) end
function onPick10() onPick(10) end
function onPick11() onPick(11) end
function onPick12() onPick(12) end
function onPick13() onPick(13) end
