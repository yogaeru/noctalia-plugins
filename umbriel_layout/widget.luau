local icon = noctalia.getConfig("icon")

function update()
	barWidget.setGlyph(icon)
end

function onClick()
	noctalia.togglePanel("yogaeru/umbriel_layout:panel")
end
