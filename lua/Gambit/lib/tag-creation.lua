local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local tags_with_multi_line_format = {
    div = true,
    ul = true,
    span = true,
}

local generate_tag = function(tag)
    if tags_with_multi_line_format[tag] then
        return string.format("<%s>\n\t###\n</%s>", tag, tag)
    else
        return string.format("<%s>###</%s>", tag, tag)
    end
end

local create_tag_at_node = function(tag, bufnr, node, next_to, count)
    local tag_content = generate_tag(tag)
    local content_tbl = lib_ts.string_to_string_tbl(tag_content)
    local repeated_table = {}

    for _ = 1, count do
        for j = 1, #content_tbl do
            table.insert(repeated_table, content_tbl[j])
        end
    end

    local start_row, _, end_row, _ = node:range()
    local node_line_text = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
    local white_spaces = string.match(node_line_text, "^(%s*)")

    for i, _ in ipairs(repeated_table) do
        repeated_table[i] = white_spaces .. repeated_table[i]
    end

    local position = next_to and end_row + 1 or start_row

    vim.api.nvim_buf_set_lines(bufnr, position, position, false, repeated_table)

    vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { position + #repeated_table, 0 })
        vim.cmd("norm! ^")
    end)
end

M.create_tag_at_cursor = function(tag, winnr, bufnr, next_to, parent, count)
    local desired_parent_types = { "jsx_element", "jsx_self_closing_element" }

    local jsx_node = lib_ts.find_parent(winnr, desired_parent_types)

    if not parent then
        create_tag_at_node(tag, bufnr, jsx_node, next_to, count)
    else
        local parent_jsx_node = lib_ts.find_parent(winnr, desired_parent_types, jsx_node)

        if parent_jsx_node then
            create_tag_at_node(tag, bufnr, parent_jsx_node, next_to, count)
        end
    end
end

return M
