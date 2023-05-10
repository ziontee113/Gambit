local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

M.myfunc = function(winnr, bufnr)
    if GAMBIT_PREVIOUS_ACTION then
        local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
        local old_classes =
            lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)
        old_classes = string.format('"%s"', old_classes)

        local current_jsx_element =
            lib_ts.find_parent(winnr, { "jsx_element", "jsx_self_closing_element" }, jsx_tag_node)

        local children = lib_ts.get_children_that_matches_types(
            current_jsx_element:parent(),
            { "jsx_element", "jsx_self_closing_element" }
        )

        for _, child in ipairs(children) do
            if child ~= current_jsx_element then
                local _, tag_node = lib_ts.get_tag_and_className_string_nodes(winnr, child)

                if tag_node then
                    if GAMBIT_PREVIOUS_ACTION == "changing-pms-classes" then
                        require("Gambit.ui.pms_menu").apply_previous_action(tag_node)
                    elseif GAMBIT_PREVIOUS_ACTION == "changing-color-classes" then
                        require("Gambit.ui.colors_menu").apply_previous_action(tag_node)
                    elseif GAMBIT_PREVIOUS_ACTION == "changing-classes-groups" then
                        require("Gambit.ui.replace_classes_menu").apply_previous_action(tag_node)
                    end
                end
            end
        end
    end
end

return M
