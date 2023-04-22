local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("Gambit.lib.tree-sitter")

local tags_with_no_content = {
    div = true,
    ul = true,
    span = true,
}

local generate_tag_content = function(tag)
    if tags_with_no_content[tag] then
        return string.format("<%s></%s>", tag, tag)
    else
        return string.format("<%s>###</%s>", tag, tag)
    end
end

local create_tag_at_node = function(opts, node)
    local default_opts = {
        tag = "div",
        bufnr = 0,
        next_to = true,
        new_line = false,
        more_spaces = false,
        count = 1,
    }
    opts = vim.tbl_deep_extend("force", default_opts, opts)

    local tag_content = generate_tag_content(opts.tag)
    local content_tbl = lib_ts.string_to_string_tbl(tag_content)
    local repeated_table = {}

    for _ = 1, opts.count do
        for j = 1, #content_tbl do
            table.insert(repeated_table, content_tbl[j])
        end
    end

    local start_row, _, end_row, end_col = node:range()
    local node_line_text =
        vim.api.nvim_buf_get_lines(opts.bufnr, start_row, start_row + 1, false)[1]

    local spaces = string.match(node_line_text, "^(%s*)")
    if opts.more_spaces then
        spaces = spaces .. "  "
    end

    for i, _ in ipairs(repeated_table) do
        repeated_table[i] = spaces .. repeated_table[i]
    end

    local position = opts.next_to and end_row + 1 or start_row

    if opts.new_line then
        table.insert(repeated_table, 1, "")
        table.insert(repeated_table, string.sub(spaces, 1, -3))
        vim.api.nvim_buf_set_text(opts.bufnr, end_row, end_col, end_row, end_col, repeated_table)
    else
        vim.api.nvim_buf_set_lines(opts.bufnr, position, position, false, repeated_table)
    end

    local move_down_by = position + #repeated_table
    if opts.new_line then
        move_down_by = move_down_by - 2
    end
    vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { move_down_by, 0 })
        vim.cmd("norm! ^")
    end)
end

M.create_tag_at_cursor = function(opts)
    local default_opts = {
        winnr = 0,
        bufnr = 0,
        tag = "p",
        inside = false,
        next_to = true,
        parent = false,
        count = 1,
    }
    opts = vim.tbl_deep_extend("force", default_opts, opts)

    local desired_parent_types = { "jsx_element", "jsx_self_closing_element" }
    local jsx_node = lib_ts.find_parent(opts.winnr, desired_parent_types)

    if opts.inside then
        if jsx_node:type() ~= "jsx_self_closing_element" then
            local children = ts_utils.get_named_children(jsx_node)
            local target = children[#children]
            local should_add_new_line, should_insert_next_to = false, false

            if #children == 2 then
                should_add_new_line = true
                should_insert_next_to = true
                target = children[1]
            end

            create_tag_at_node({
                tag = opts.tag,
                bufnr = opts.bufnr,
                next_to = should_insert_next_to,
                new_line = should_add_new_line,
                more_spaces = true,
                count = opts.count,
            }, target)
        end
    else
        if not opts.parent then
            create_tag_at_node({
                tag = opts.tag,
                bufnr = opts.bufnr,
                next_to = opts.next_to,
                count = opts.count,
            }, jsx_node)
        else
            local parent_jsx_node = lib_ts.find_parent(opts.winnr, desired_parent_types, jsx_node)

            if parent_jsx_node then
                create_tag_at_node({
                    tag = opts.tag,
                    bufnr = opts.bufnr,
                    next_to = opts.next_to,
                    count = opts.count,
                }, parent_jsx_node)
            end
        end
    end
end

return M
