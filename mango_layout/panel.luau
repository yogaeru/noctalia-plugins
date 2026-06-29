local layouts = {
	T  = { name = "tile",             label= "Tile",               glyph = "layout-sidebar" },
	S  = { name = "scroller",         label= "Scroller",           glyph = "carousel-horizontal" },
	M  = { name = "monocle",          label= "Monocle",            glyph = "square" },
	G  = { name = "grid",             label= "Grid",               glyph = "layout-grid" },
	F  = { name = "fair",             label= "Fair",               glyph = "layout-board-split" },
	D  = { name = "deck",             label= "Deck",               glyph = "layers-difference" },
	DW = { name = "dwindle",          label= "Dwindle",            glyph = "layout-2" },
	CT = { name = "center_tile",      label= "Center Tile",        glyph = "layout-distribute-vertical" },
	VT = { name = "vertical_tile",    label= "Vertical Tile",      glyph = "layout-rows" },
	RT = { name = "right_tile",       label= "Right Tile",         glyph = "layout-sidebar-right" },
	VS = { name = "vertical_scroller",label= "Vertical Scroller",  glyph = "carousel-vertical" },
	VG = { name = "vertical_grid",    label= "Vertical Grid",      glyph = "grid-dots" },
	VD = { name = "vertical_deck",    label= "Vertical Deck",      glyph = "chart-funnel" },
	VF = { name = "vertical_fair",    label= "Vertical Fair",      glyph = "layout-board" },
}

local closeOnSelect = noctalia.getConfig("closeOnSelect")
local compactLabel = noctalia.getConfig("compactLabel")

local COLUMNS    = 3
local COLUMN_GAP = 4
local selectedLayout = ""
local pickSlots = {}

-- declare render function var
local render

local function onPickAt(index)
	local slot = pickSlots[index]
	if slot == nil then return end
	selectedLayout = slot.sym
	noctalia.runAsync(`mmsg dispatch "setlayout, {slot.entry.name}"`)
	if closeOnSelect then panel.close() else render() end
end

local function makeGrid(children)
	local rows = {}
	local row  = {}
	for i, child in ipairs(children) do
		table.insert(row, child)
		if #row >= COLUMNS or i == #children then
			while #row < COLUMNS do
				table.insert(row, ui.spacer({ flexGrow = 1 }))
			end
			table.insert(rows, ui.row({ gap = COLUMN_GAP, align = "stretch" }, row))
			row = {}
		end
	end
	return ui.column({ gap = COLUMN_GAP }, rows)
end

local function renderButtons()
	local buttons = {}
	local i = 0
	for sym, entry in pairs(layouts) do
		local slotIndex  = i
		local isSelected = selectedLayout == sym
		local labelName = if compactLabel then sym else entry.label
		pickSlots[slotIndex] = { sym = sym, entry = entry }
		
		table.insert(buttons, ui.column({
			key      = sym,
			gap      = 4,
			align    = "center",
			flexGrow = 1,
		}, {
			ui.button({
				glyph   = entry.glyph,
				glyphSize = 28,
				variant = if isSelected then "primary" else "ghost",
				onClick = `onPick{slotIndex}`,
			}),
			ui.label({
				text      = labelName,
				fontSize  = 12,
				fontWeight = "bold",
				color     = if isSelected then "primary" else "on_surface_variant",
				textAlign = "center",
				maxLines  = 1,
			}),
		}))

		-- increment index
		i += 1
	end
	return buttons
end

render = function()
	pickSlots = {}
	panel.render(ui.column({ }, {
		ui.scroll({ flexGrow = 1 }, {
			ui.column({ padding = 12, gap = COLUMN_GAP }, {
				makeGrid(renderButtons()),
			}),
		}),
	}))
end

function onOpen(context)
	selectedLayout = ""
	render()

	noctalia.runAsync(
		"mmsg get all-monitors | jq -r '.monitors[] | select(.active == true and .last_open_surface != null) | .layout_symbol'",
		function(result)
			if result == nil or result.exitCode ~= 0 then return end
			local sym = result.stdout:gsub("%s+", "")
			selectedLayout = if layouts[sym] then sym else ""
			render()
		end
	)
end

function onCloseClicked()
	panel.close()
end

function onPick0()  onPickAt(0)  end
function onPick1()  onPickAt(1)  end
function onPick2()  onPickAt(2)  end
function onPick3()  onPickAt(3)  end
function onPick4()  onPickAt(4)  end
function onPick5()  onPickAt(5)  end
function onPick6()  onPickAt(6)  end
function onPick7()  onPickAt(7)  end
function onPick8()  onPickAt(8)  end
function onPick9()  onPickAt(9)  end
function onPick10() onPickAt(10) end
function onPick11() onPickAt(11) end
function onPick12() onPickAt(12) end
function onPick13() onPickAt(13) end