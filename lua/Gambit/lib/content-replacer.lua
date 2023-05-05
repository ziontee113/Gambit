local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local get_jsx_text_node = function(winnr)
    local jsx_node = lib_ts.find_parent(winnr, { "jsx_element" })
    local text_nodes = lib_ts.get_children_that_matches_types(jsx_node, { "jsx_text" })
    local opening_tag_node =
        lib_ts.get_children_that_matches_types(jsx_node, { "jsx_opening_element" })[1]
    return text_nodes[1], opening_tag_node
end

M.replace_jsx_text = function(winnr, bufnr, replacement)
    local text_node, opening_node = get_jsx_text_node(winnr)
    if text_node then
        lib_ts.replace_node_text(bufnr, text_node, replacement)
    else
        local _, _, end_row, end_col = opening_node:range()
        vim.api.nvim_buf_set_text(bufnr, end_row, end_col, end_row, end_col, { replacement })
    end
end

return M
