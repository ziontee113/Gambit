local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local vim_utils = require("Gambit.lib.vim-utils")
local lib_ts = require("Gambit.lib.tree-sitter")

local empty_tags = {
    div = true,
    ul = true,
    span = true,
}

local formatted_tags = {
    Image = [[
<Image
  src="img.jpg"
  alt=""
  style={{ objectFit: 'cover' }}
  fill
/>]],
}

local generate_tag_content = function(tag, content)
    if formatted_tags[tag] then
        return formatted_tags[tag]
    elseif empty_tags[tag] then
        return string.format("<%s></%s>", tag, tag)
    else
        return string.format("<%s>%s</%s>", tag, content or "###", tag)
    end
end

local repeat_tag_content = function(content_tbl, count)
    local new_tbl = {}
    for _ = 1, count do
        for j = 1, #content_tbl do
            table.insert(new_tbl, content_tbl[j])
        end
    end
    return new_tbl
end

local add_spacing_to_content_tbl = function(content_tbl, start_row, should_add_new_line)
    local node_line_text = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]

    local spaces = string.match(node_line_text, "^(%s*)")
    if should_add_new_line then
        spaces = spaces .. "  "
    end

    local new_tbl = {}
    for i, _ in ipairs(content_tbl) do
        table.insert(new_tbl, spaces .. content_tbl[i])
    end

    return new_tbl, spaces
end

local add_new_lines_to_content_tbl = function(content_tbl, should_add_new_line, spaces)
    if should_add_new_line then
        table.insert(content_tbl, 1, "")
        table.insert(content_tbl, string.sub(spaces, 1, -3))
    end
    return content_tbl
end

local create_tag_at_node = function(tag, node, should_add_new_line, count)
    local start_row, _, end_row, end_col = node:range()

    local tag_content = generate_tag_content(tag)
    local content_tbl, spaces = vim_utils.string_to_string_tbl(tag_content), nil
    content_tbl = repeat_tag_content(content_tbl, count)
    content_tbl, spaces = add_spacing_to_content_tbl(content_tbl, start_row, should_add_new_line)
    content_tbl = add_new_lines_to_content_tbl(content_tbl, should_add_new_line, spaces)

    if should_add_new_line then
        vim.api.nvim_buf_set_text(0, end_row, end_col, end_row, end_col, content_tbl)
    else
        vim.api.nvim_buf_set_lines(0, end_row + 1, end_row + 1, false, content_tbl)
    end
end

M.create_tag_at_cursor = function(tag, destination, count)
    local desired_types = { "jsx_element", "jsx_self_closing_element", "jsx_fragment" }
    local jsx_node = lib_ts.find_parent(0, desired_types)

    if jsx_node:type() == "jsx_fragment" then
        local children = lib_ts.get_children_nodes(jsx_node)
        local target = children[2]
        local should_add_new_line = true

        create_tag_at_node(tag, target, should_add_new_line, count)
        return should_add_new_line
    else
        if destination == "inside" and jsx_node:type() ~= "jsx_self_closing_element" then
            local children = ts_utils.get_named_children(jsx_node)
            local jsx_children = lib_ts.get_children_that_matches_types(jsx_node, desired_types)

            local target, should_add_new_line

            if #jsx_children > 0 then
                target = jsx_children[#jsx_children]
                should_add_new_line = false
            else
                target = children[#children - 1]
                should_add_new_line = true
            end

            create_tag_at_node(tag, target, should_add_new_line, count)
            return should_add_new_line
        elseif destination == "next-to" then
            create_tag_at_node(tag, jsx_node, false, count)
        end
    end
end

return M
