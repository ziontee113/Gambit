local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local get_prop_node = function(winnr, prop_name)
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
        string.format(
            [[ ;query
(jsx_attribute
  (property_identifier) @prop_ident (#eq? @prop_ident "%s")
  (string) @string
)
]],
            prop_name
        ),
        "tsx",
        root,
        { "string" }
    )

    local prop_string_node = matched_groups["string"][1]
    return prop_string_node
end

M.replace_prop = function(winnr, bufnr, prop_name, replacement)
    local prop_string_node = get_prop_node(winnr, prop_name)
    lib_ts.replace_node_text(bufnr, prop_string_node, string.format([["%s"]], replacement))
end

return M
