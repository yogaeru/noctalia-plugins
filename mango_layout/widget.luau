local layoutsIcon = {
	T = "layout-sidebar",
	S = "carousel-horizontal",
	M = "square",
	G = "layout-grid",
	F = "layout-board-split",
	D = "layers-difference",
	DW = "layout-2",
	CT = "layout-distribute-vertical",
	VT = "layout-rows",
	RT = "layout-sidebar-right",
	VS = "carousel-vertical",
	VG = "grid-dots",
	VD = "chart-funnel",
	VF = "layout-board",
}

local activeIcon = ""
local icon = barWidget.getConfig("icon")
local dynamicIcon = barWidget.getConfig("dynamicIcon")

if dynamicIcon then
	noctalia.runStream("mmsg watch all-tags", function(line)
		local ok, data = pcall(noctalia.json.decode, line)
		if not ok or not data or not data.all_tags then
			return
		end

		for _, monitor in ipairs(data.all_tags) do
			for _, tag in ipairs(monitor.tags) do
				if tag.is_active then
					local layout = tag.layout
					local layoutIcon = layoutsIcon[layout]
					if activeIcon == layoutIcon then
						return
					end

					noctalia.state.set("activeLayout", layout)
					barWidget.setGlyph(layoutIcon)

					noctalia.notify("Info", ("Layout switched to %s"):format(layout))
					activeIcon = layoutIcon

					return
				end
			end
		end
	end)
end

function update()
	noctalia.setUpdateInterval(1000)
	barWidget.setTooltip("Switch Layout")
	if not dynamicIcon then
		barWidget.setGlyph(icon)
		if dynamicIcon ~= noctalia.state.get("iconFollowLayout") then
			noctalia.state.set("iconFollowLayout", dynamicIcon)
			noctalia.notify("Update Widget", `{noctalia.state.get("iconFollowLayout")}`)
		end
	end
	-- noctalia.notify("Update Icon", "test")
end

function onClick()
	noctalia.togglePanel("yogaeru/mango_layout:main")
end

-- IPC handler
-- Usage
-- noctalia msg plugin yogaeru/mango_layout:picker focused open
function onIpc(event)
	if event == "open" then
		noctalia.togglePanel("yogaeru/mango_layout:main")
	end
end
