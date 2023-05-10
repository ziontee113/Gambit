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

M.apply_classes_group = function(win, buf, classes_groups, item_data, placement, negatives, node)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(win, node)
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

M.change_tailwind_colors = function(opts)
    local className_string_node, jsx_tag_node =
        lib_ts.get_tag_and_className_string_nodes(opts.winnr, opts.node)
    local old_classes =
        lib_ts.get_classes_from_className_string_node(className_string_node, opts.bufnr)

    local new_classes =
        classes_manipulator.replace_tailwind_color_classes(old_classes, opts.replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(opts.bufnr, jsx_tag_node, className_string_node, new_classes)
    GAMBIT_PREVIOUS_ACTION = "changing-color-classes"
end

M.change_pms_classes = function(opts)
    local className_string_node, jsx_tag_node =
        lib_ts.get_tag_and_className_string_nodes(opts.winnr, opts.node)
    local old_classes =
        lib_ts.get_classes_from_className_string_node(className_string_node, opts.bufnr)

    local new_classes =
        classes_manipulator.remove_pms_classes(old_classes, opts.property, opts.axies_to_remove)

    new_classes = classes_manipulator.replace_pms_classes(
        new_classes,
        opts.property,
        opts.axis,
        opts.replacement
    )

    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(opts.bufnr, jsx_tag_node, className_string_node, new_classes)
    GAMBIT_PREVIOUS_ACTION = "changing-pms-classes"
end

M.change_pseudo_element_conent = function(winnr, bufnr, replacement)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes = classes_manipulator.replace_pseudo_element_content(old_classes, replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
end

M.replicate_all_classes_to_all_siblings = function(winnr, bufnr)
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)
    old_classes = string.format('"%s"', old_classes)

    local current_jsx_element =
        lib_ts.find_parent(winnr, { "jsx_element", "jsx_self_closing_element" }, jsx_tag_node)
    local children = lib_ts.get_children_that_matches_types(
        current_jsx_element:parent(),
        { "jsx_element", "jsx_self_closing_element" }
    )

    for _, child in ipairs(children) do
        if child ~= current_jsx_element then
            local string_node, tag_node = lib_ts.get_tag_and_className_string_nodes(winnr, child)

            apply_new_classes(bufnr, tag_node, string_node, old_classes)
        end
    end
end

return M
