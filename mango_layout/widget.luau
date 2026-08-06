
function update()
  noctalia.setUpdateInterval(0)
  barWidget.setGlyph("layout-filled")
  barWidget.setTooltip("Mango Layout")
end

function onClick()
  noctalia.togglePanel("yogaeru/mango_layout:main")
end

-- IPC handler
-- Usage 
-- noctalia msg plugin yogaeru/mango_layout:main open
function onIpc(event)
	if event == "open" then
	noctalia.togglePanel("yogaeru/mango_layout:main")
	end
end
