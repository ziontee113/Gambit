local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local get_jsx_text_node = function(winnr)
    local jsx_node = lib_ts.find_parent(winnr, { "jsx_element" })
    local text_nodes = lib_ts.get_children_that_matches_types(jsx_node, { "jsx_text" })
    return text_nodes[1]
end

M.replace_jsx_text = function(winnr, bufnr, replacement)
    local text_node = get_jsx_text_node(winnr)
    lib_ts.replace_node_text(bufnr, text_node, { replacement })
end

return M
