local M = {}

local mandatory_events = require("Gambit.api.mandatory_events")
local indicator = require("Gambit.ui.state_indicator")
local lib_mixer = require("Gambit.lib.pseudo-classes-mixer")

M.show = function()
    local indicator_popup = mandatory_events._indicator_popup()
    local Input = require("nui.input")

    local popup_options = {
        relative = "cursor",
        enter = true,
        position = {
            row = 1,
            col = 0,
        },
        size = 20,
        border = {
            style = "rounded",
            text = {
                top = "[Pseudo Class]",
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:@function",
        },
    }

    local input = Input(popup_options, {
        prompt = "> ",
        default_value = "",
        on_change = function(value)
            vim.schedule(function()
                PSEUDO_CLASSES = lib_mixer.translate_alias_string(value)
                indicator.update(indicator_popup)
            end)
        end,
    })

    input:mount()

    -------------------------------------------- Mappings

    -- unmount the input while preserving current PSEUDO_CLASSES
    input:map("i", { "<Space>", "<Tab>" }, function()
        input:unmount()
    end, {})

    -- restore default <C-w> behavior in Insert Mode
    input:map("i", "<C-w>", "<C-S-w>", { noremap = true })

    -- clear current PSEUDO_CLASSES
    input:map("i", { "<Esc>" }, function()
        PSEUDO_CLASSES = ""
        indicator.update(indicator_popup)
        input:unmount()
    end, { noremap = true })
end

return M
