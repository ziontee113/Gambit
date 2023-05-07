local M = {}

local colors_menu_module = require("Gambit.ui.colors_menu")
local class_replacer = require("Gambit.lib.class-replacer")
local transformer = require("Gambit.lib.arbitrary-value-transformer")

M.show = function(winnr, bufnr, property)
    local callback = function(input)
        local color = transformer.input_to_color(input)
        local class = transformer.wrap_value_in_property(color, property)
        local change_arguments = { winnr, bufnr, { [property] = class } }

        colors_menu_module.change_arguments(change_arguments)
        class_replacer.change_tailwind_colors(unpack(change_arguments))
    end

    require("Gambit.lib.input-maker").create_input(property .. " input", callback)
end

return M
