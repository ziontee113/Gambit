local M = {}

local class_replacer = require("Gambit.lib.class-replacer")

M.show = function(winnr, bufnr)
    local callback = function(content)
        class_replacer.change_pseudo_element_conent(winnr, bufnr, content)
    end
    local quit_callback = function()
        class_replacer.change_pseudo_element_conent(winnr, bufnr, nil)
    end

    require("Gambit.lib.input-maker").create_input(
        PSEUDO_CLASSES .. " content",
        callback,
        quit_callback
    )
end

return M
