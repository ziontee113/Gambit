local M = {}

local visual_mode = require("Gambit.lib.visual-mode")
local navigation = require("Gambit.api.navigation")

local indicator = require("Gambit.ui.state_indicator")
local indicator_popup

M.enter = function()
    navigation.jump_and_highlight({ direction = "in-place" })

    PSEUDO_CLASSES = ""
    indicator_popup = indicator.initiate()
end

M.exit = function()
    navigation._clear_namespace()
    visual_mode.deactivate()

    if indicator_popup then
        indicator_popup:unmount()
    end
end

return M
