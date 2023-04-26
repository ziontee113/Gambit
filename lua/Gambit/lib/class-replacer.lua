local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")
local classes_manipulator = require("Gambit.lib.class-manipulator")

M.myfunc = function(winnr, bufnr, classes_groups, item)
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

    local className_string_node = matched_groups["string"][1]

    local old_classes = ""
    if className_string_node then
        old_classes = vim.treesitter.get_node_text(className_string_node, bufnr)
        old_classes = string.gsub(old_classes, "[\"']", "")
    end

    local new_classes =
        classes_manipulator.replace_classes_with_list_item(old_classes, classes_groups, item.data)
    new_classes = string.format('"%s"', new_classes)

    local jsx_tag_node = lib_ts.get_children_that_matches_types(root, { "identifier" })[1]

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

return M
