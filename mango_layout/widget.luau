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

local config = {
    dynamicIcon = false,
    icon = "layout-filled",
}

local watcherStarted = false
local currentGlyph = ""

--------------------------------------------------
-- Config
--------------------------------------------------

local function reloadConfig()
    config.dynamicIcon = noctalia.getConfig("dynamic_icon") == true
    config.icon = noctalia.getConfig("icon") or "layout-filled"
end

--------------------------------------------------
-- Widget
--------------------------------------------------

local function setGlyph(glyph)
    if not glyph or glyph == currentGlyph then
        return
    end

    currentGlyph = glyph
    barWidget.setGlyph(glyph)
end

local function refreshCurrentLayout()
    noctalia.runAsync(
        [[mmsg get all-monitors | jq -r '.monitors[] | select(.active == true and .last_open_surface != null) | .layout_symbol']],
        function(result)
            if not result or result.exitCode ~= 0 then
                return
            end

            local symbol = result.stdout:gsub("%s+", "")
            local glyph = layoutsIcon[symbol]

            if glyph then
                setGlyph(glyph)
            end
        end
    )
end

--------------------------------------------------
-- Watch
--------------------------------------------------

local function startWatcher()
    if watcherStarted then
        return
    end

    watcherStarted = true

    noctalia.runStream("mmsg watch all-tags", function(line)
        if not config.dynamicIcon then
            return
        end

        local data = noctalia.json.decode(line)

        if not data or not data.all_tags then
            return
        end

        for _, monitor in ipairs(data.all_tags) do
            for _, tag in ipairs(monitor.tags) do
                if tag.is_active then
                    local glyph = layoutsIcon[tag.layout]

                    if glyph then
                        setGlyph(glyph)
                    end

                    return
                end
            end
        end
    end)
end

--------------------------------------------------
-- Lifecycle
--------------------------------------------------

reloadConfig()

function update()
    noctalia.setUpdateInterval(0)

    barWidget.setTooltip("Switch Layout")

    startWatcher()

    if config.dynamicIcon then
        refreshCurrentLayout()
    else
        setGlyph(config.icon)
    end
end

function onConfigChanged()
    reloadConfig()

    currentGlyph = ""

    if config.dynamicIcon then
        refreshCurrentLayout()
    else
        setGlyph(config.icon)
    end
end

--------------------------------------------------
-- Actions
--------------------------------------------------

function onClick()
    noctalia.togglePanel("yogaeru/mango_layout:main")
end

function onIpc(event)
    if event == "open" then
        noctalia.togglePanel("yogaeru/mango_layout:main")
    end
end