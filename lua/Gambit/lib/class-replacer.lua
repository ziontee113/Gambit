local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")
local classes_manipulator = require("Gambit.lib.classes-manipulator")

local apply_new_classes = function(bufnr, jsx_tag_node, className_string_node, new_classes)
    if jsx_tag_node then
        if className_string_node then
            lib_ts.replace_node_text(bufnr, className_string_node, new_classes)
        else
            local _, _, end_row, end_col = jsx_tag_node:range()
            vim.api.nvim_buf_set_text(
                bufnr,
                end_row,
                end_col,
                end_row,
                end_col,
                { string.format(" className=%s", new_classes) }
            )
        end
    end
end

M.apply_classes_group = function(win, buf, classes_groups, item_data, placement, negatives)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(win)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, buf)

    local new_classes = classes_manipulator.replace_classes_with_list_item(
        old_classes,
        classes_groups,
        item_data.classes,
        placement,
        negatives
    )
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(buf, jsx_tag_node, className_string_node, new_classes)
    GAMBIT_PREVIOUS_ACTION = "changing-classes-groups"
end

M.change_tailwind_colors = function(winnr, bufnr, replacement)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes = classes_manipulator.replace_tailwind_color_classes(old_classes, replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
    GAMBIT_PREVIOUS_ACTION = "changing-color-classes"
end

M.change_pms_classes = function(winnr, bufnr, property, axis, axies_to_remove, replacement)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes =
        classes_manipulator.remove_pms_classes(old_classes, property, axies_to_remove)
    new_classes = classes_manipulator.replace_pms_classes(new_classes, property, axis, replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
    GAMBIT_PREVIOUS_ACTION = "changing-pms-classes"
end

M.change_pseudo_element_conent = function(winnr, bufnr, replacement)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes = classes_manipulator.replace_pseudo_element_content(old_classes, replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
end

return M
