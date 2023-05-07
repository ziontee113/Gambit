local M = {}

local colors_menu_module = require("Gambit.ui.colors_menu")
local class_replacer = require("Gambit.lib.class-replacer")
local transformer = require("Gambit.lib.arbitrary-color-transformer")

M.show = function(winnr, bufnr, property)
    local Input = require("nui.input")
    local border_top_text = string.format("[%s color]", property)

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
                top = border_top_text,
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
        on_submit = function(input)
            local color = transformer.input_to_color(input)
            local class = transformer.wrap_color_in_property(color, property)
            local change_arguments = { winnr, bufnr, { [property] = class } }

            colors_menu_module.change_arguments(change_arguments)
            class_replacer.change_tailwind_colors(unpack(change_arguments))
        end,
    })

    input:mount()

    -------------------------------------------- Mappings

    -- keys to unmount the input
    input:map("i", { "<Space>", "<Tab>", "<Esc>" }, function()
        input:unmount()
    end, {})

    -- restore default <C-w> behavior in Insert Mode
    input:map("i", "<C-w>", "<C-S-w>", { noremap = true })
end

return M
