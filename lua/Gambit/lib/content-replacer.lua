local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local get_jsx_text_node = function(winnr)
    local jsx_node = lib_ts.find_parent(winnr, { "jsx_element" })
    local text_nodes = lib_ts.get_children_that_matches_types(jsx_node, { "jsx_text" })
    local opening_tag_node =
        lib_ts.get_children_that_matches_types(jsx_node, { "jsx_opening_element" })[1]
    return text_nodes[1], opening_tag_node
end

local replace_jsx_text = function(winnr, bufnr, replacement)
    if type(replacement) == "string" then
        if string.match(replacement, "\n") then
            replacement = vim.split(replacement, "\n")
        else
            replacement = { replacement }
        end
    end

    local text_node, opening_node = get_jsx_text_node(winnr)
    if text_node then
        lib_ts.replace_node_text(bufnr, text_node, replacement)
    else
        local _, _, end_row, end_col = opening_node:range()
        vim.api.nvim_buf_set_text(bufnr, end_row, end_col, end_row, end_col, replacement)
    end
end

M.replace_jsx_text = function(winnr, bufnr, replacement)
    replace_jsx_text(winnr, bufnr, replacement)
end

M.replace_jsx_text_with_expression = function(winnr, bufnr)
    local _, opening_node = get_jsx_text_node(winnr)
    local start_row = opening_node:range()

    local opening_tag_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)
    local indent = string.match(opening_tag_line[1], "^%s+")

    local replacement = { "", "  {", "    ", "  }", "" }
    for i, line in ipairs(replacement) do
        replacement[i] = indent .. line
    end

    replace_jsx_text(winnr, bufnr, replacement)

    vim.schedule(function()
        vim.cmd("norm! 2k")
        vim.api.nvim_input("A")
    end)
end

return M
