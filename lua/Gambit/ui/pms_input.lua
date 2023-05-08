local M = {}

local pms_menu_module = require("Gambit.ui.pms_menu")
local class_replacer = require("Gambit.lib.class-replacer")
local transformer = require("Gambit.lib.arbitrary-value-transformer")

M.show = function(winnr, bufnr, property, axis, axies_to_remove)
    local callback = function(input)
        local pms_value = transformer.input_to_pms_value(input)
        local class = transformer.wrap_value_in_property(pms_value, property .. axis)
        local change_arguments = {
            winnr,
            bufnr,
            property,
            axis,
            axies_to_remove,
            class,
        }
        class_replacer.change_pms_classes(unpack(change_arguments))
        pms_menu_module.change_arguments(change_arguments)
    end

    require("Gambit.lib.input-maker").create_input("[TBD]", callback)
end

return M
