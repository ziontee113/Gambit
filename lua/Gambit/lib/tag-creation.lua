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

local create_tag_at_node = function(tag, bufnr, node, next_to)
    local tag_content = generate_tag(tag)
    local content_tbl = lib_ts.string_to_string_tbl(tag_content)

    local start_row, _, end_row, _ = node:range()

    if next_to then
        vim.api.nvim_buf_set_lines(bufnr, end_row + 1, end_row + 1, false, content_tbl)
    else
        vim.api.nvim_buf_set_lines(bufnr, start_row, start_row, false, content_tbl)
    end
end

M.create_tag_at_cursor = function(tag, winnr, bufnr, next_to, parent)
    local desired_parent_types = { "jsx_element", "jsx_self_closing_element" }

    local jsx_node = lib_ts.find_parent_on_cursor(winnr, desired_parent_types)

    if not parent then
        create_tag_at_node(tag, bufnr, jsx_node, next_to)
    else
        local parent_jsx_node = lib_ts.find_parent_on_cursor(winnr, desired_parent_types, jsx_node)

        if parent_jsx_node then
            create_tag_at_node(tag, bufnr, parent_jsx_node, next_to)
        end
    end
end

return M
