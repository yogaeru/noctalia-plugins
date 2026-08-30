local layouts = {
	scrolling = {
		label = "Scrolling",
		icon = "carousel-horizontal",
	},
	master = {
		label = "Master",
		icon = "layout-board-split",
	},
	dwindle = {
		label = "Dwindle",
		icon = "layout-2",
	},
}

local layoutList = {
	"scrolling",
	"dwindle",
	"master",
}

local closeOnSelect = noctalia.getConfig("close_on_select")

local focus = -1
local activeLayout
local COLUMNS = 3
local GAP = 4

-- Make a grid from created buttons
function makeGrid(children: { UiNode })
	local rows = {}
	local row = {}

	-- loop button that have we built
	for i, child in ipairs(children) do
		table.insert(row, child)

		if #row == COLUMNS or i == #children then
			while #row < COLUMNS do
				table.insert(row, ui.spacer({ flexGrow = 1 }))
			end

			-- Insert row into rows
			table.insert(
				rows,
				ui.row({
					gap = GAP,
					align = "stretch",
				}, row)
			)

			-- reset row
			row = {}
		end
	end

	return ui.column({}, rows)
end

-- Build buttons for the layout selection
function buildButtons()
	local buttons = {}

	for index, value in ipairs(layoutList) do
		local layout = layouts[value]
		local selected = (activeLayout == value)
		if selected and focus == -1 then
			focus = index - 1
		end

		table.insert(
			buttons,
			ui.column({
				align = "center",
				flexGrow = 1,
			}, {
				-- Icon button
				ui.button({
					glyphSize = 32,
					glyph = layout.icon,
					variant = selected and "primary" or "ghost",
					onClick = function()
						switchLayout(value)
					end,
					selected = focus == index - 1,
				}),

				-- Label button
				ui.label({
					text = layout.label,
					fontSize = 12,
					fontWeight = "bold",
					textAlign = "center",
					color = selected and "primary" or "on_surface_variant",
				}),

				-- End
			})
		)
	end

	return buttons
end

-- Parse workspaces from the output of the workspace command
local function parseWorkspaces(text)
	local results = {}

	for line in text:gmatch("[^\n]+") do
		local marker, output, ws, layout = line:match("^(%*?)%s*(%S+):%s*(%S+)%s*%[(%a+)%]")
		if output then
			local focused = (marker == "*") or (line:find("%(focused%)") ~= nil)
			table.insert(results, {
				output = output,
				workspace = ws,
				layout = layout,
				focused = focused,
			})
		end
	end

	return results
end

-- Get the focused layout from the parsed workspaces
local function getFocusedLayout(text)
	for _, item in ipairs(parseWorkspaces(text)) do
		if item.focused then
			return item.layout, item.output, item.workspace
		end
	end
	return nil
end

local function render()
	panel.render(ui.column({
		flexGrow = 1,
		justify = "center",
		-- border = "outline",
	}, {
		makeGrid(buildButtons()),
	}))
end

-- Changing layout
function switchLayout(layout: string)
	-- noctalia.notify("Change Layout", layout)

	noctalia.runAsync(string.format("umbriel msg workspace-set-layout:%s", layout))
	activeLayout = layout

	if closeOnSelect then
		panel.close()
	else
		focus = -1
		render()
	end
end

function onKey(chord, pressed)
	if not pressed then
		return
	end

	if chord == "1" then
		switchLayout(layoutList[1])
	elseif chord == "2" then
		switchLayout(layoutList[2])
	elseif chord == "3" then
		switchLayout(layoutList[3])
	elseif chord == "left" or chord == "h" then
		focus = (focus - 1) % #layoutList
		render()
	elseif chord == "right" or chord == "l" then
		focus = (focus + 1) % #layoutList
		render()
	elseif chord == "return" then
		local layoutSelected = layoutList[focus + 1]
		if layoutSelected ~= activeLayout then
			switchLayout(layoutSelected)
		end
	end
end

function onOpen()
	noctalia.runAsync("umbriel workspaces", function(result: CommandResult)
		activeLayout = getFocusedLayout(result.stdout)
		-- noctalia.notify("Workspace", activeLayout)
		render()
	end)
end

function onClose()
	focus = -1
end
