local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")
local classes_manipulator = require("Gambit.lib.classes-manipulator")

local get_tag_and_className_string_nodes = function(winnr)
    local desired_types = { "jsx_element", "jsx_self_closing_element" }
    local jsx_node = lib_ts.find_parent(winnr, desired_types)

    local root
    if jsx_node:type() == "jsx_element" then
        local opening_element =
            lib_ts.get_children_that_matches_types(jsx_node, { "jsx_opening_element" })[1]
        root = opening_element
    elseif jsx_node:type() == "jsx_self_closing_element" then
        root = jsx_node
    end

    local _, matched_groups = lib_ts.get_all_nodes_matches_query(
        [[ ;query
(jsx_attribute
  (property_identifier) @prop_ident (#eq? @prop_ident "className")
  (string) @string
)
]],
        "tsx",
        root,
        { "string" }
    )

    local jsx_tag_node = lib_ts.get_children_that_matches_types(root, { "identifier" })[1]
    local className_string_node = matched_groups["string"][1]

    return className_string_node, jsx_tag_node
end

local get_classes_from_className_string_node = function(className_string_node, bufnr)
    local old_classes = ""
    if className_string_node then
        old_classes = vim.treesitter.get_node_text(className_string_node, bufnr)
        old_classes = string.gsub(old_classes, "[\"']", "")
    end

    return old_classes
end

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

M.apply_classes_group = function(winnr, bufnr, classes_groups, item_data)
    local className_string_node, jsx_tag_node = get_tag_and_className_string_nodes(winnr)
    local old_classes = get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes =
        classes_manipulator.replace_classes_with_list_item(old_classes, classes_groups, item_data)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
end

M.change_tailwind_colors = function(winnr, bufnr, replacement)
    local className_string_node, jsx_tag_node = get_tag_and_className_string_nodes(winnr)
    local old_classes = get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes = classes_manipulator.replace_tailwind_color_classes(old_classes, replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
end

M.change_pms_classes = function(winnr, bufnr, property, axis, axies_to_remove, replacement)
    local className_string_node, jsx_tag_node = get_tag_and_className_string_nodes(winnr)
    local old_classes = get_classes_from_className_string_node(className_string_node, bufnr)

    local new_classes =
        classes_manipulator.remove_pms_classes(old_classes, property, axies_to_remove)
    new_classes = classes_manipulator.replace_pms_classes(new_classes, property, axis, replacement)
    new_classes = string.format('"%s"', new_classes)

    apply_new_classes(bufnr, jsx_tag_node, className_string_node, new_classes)
    GAMBIT_PREVIOUS_ACTION = "changing-classes"
end

return M
