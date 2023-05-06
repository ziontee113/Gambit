local M = {}

local Popup = require("nui.popup")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")

M.initiate = function()
    local popup = Popup({
        position = {
            row = "50%",
            col = "100%",
        },
        size = {
            width = 20,
            height = 1,
        },
        enter = false,
        focusable = false,
        zindex = 50,
        relative = "editor",
        border = {
            padding = {
                top = 0,
                bottom = 0,
                left = 1,
                right = 1,
            },
            style = "rounded",
            text = {
                top = " Class Mode ",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })

    popup:mount()

    return popup
end

local calculate_win_width = function(state, border_text)
    if #state > #border_text then
        return #state
    else
        return #border_text
    end
end

local center_state_text = function(state, win_width)
    local spaces = (win_width - #state) / 2
    return string.rep(" ", spaces) .. state
end

M.update = function(popup)
    local border_text = " Class Mode "
    if PSEUDO_CLASSES == "" then
        popup:hide()
    else
        local win_width = calculate_win_width(PSEUDO_CLASSES, border_text)

        local text = NuiText(center_state_text(PSEUDO_CLASSES, win_width), "Normal")
        local line = NuiLine({ text })
        line:render(popup.bufnr, -1, 1)

        popup:update_layout({
            position = {
                row = "50%",
                col = "100%",
            },
            size = {
                width = win_width,
                height = 1,
            },
        })

        popup.border:set_text("top", border_text, "center")
        popup.border:set_highlight("@function")
        popup:show()
    end
end

return M
