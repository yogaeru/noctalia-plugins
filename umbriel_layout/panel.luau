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

local closeOnSelect = noctalia.getConfig("close_on_select")
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

	for key, value in pairs(layouts) do
		local selected = (activeLayout == key)
		-- Create a button and insert it into the buttons table
		table.insert(
			buttons,
			ui.column({
				-- gap = GAP,
				align = "center",
				flexGrow = 1,
			}, {
				-- Icon button
				ui.button({
					glyphSize = 28,
					glyph = value.icon,
					variant = selected and "primary" or "ghost",
					onClick = function()
						changeLayout(key)
					end,
				}),

				-- Label button
				ui.label({
					text = value.label,
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
	}, {
		makeGrid(buildButtons()),
	}))
end

function onOpen()
	noctalia.runAsync("umbriel workspaces", function(result: CommandResult)
		activeLayout = getFocusedLayout(result.stdout)
		-- noctalia.notify("Workspace", activeLayout)
		render()
	end)

	render()
end

-- Changing layout
function changeLayout(layout: string)
	-- noctalia.notify("Change Layout", layout)
	noctalia.runAsync(string.format("umbriel msg workspace-set-layout:%s", layout))
	activeLayout = layout
	if closeOnSelect then
		panel.close()
	else
		render()
	end
end
