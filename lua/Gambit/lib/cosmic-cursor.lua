local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local get_closest_node_to_cursor = function(nodes, winnr)
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(winnr))
    cursor_row = cursor_row - 1

    local closest_distance = math.huge
    local closest_node, closest_index = nil, nil

    for i, node in ipairs(nodes) do
        local start_row, start_col, end_row, end_col = node:range()
        local center_row = (start_row + end_row) / 2
        local center_col = (start_col + end_col) / 2
        local distance = math.sqrt((cursor_row - center_row) ^ 2 + (cursor_col - center_col) ^ 2)
        if distance <= closest_distance then
            closest_distance = distance
            closest_node = node
            closest_index = i
        end
    end

    return closest_node, closest_index
end

local adjust_index_base_on_direction = function(nodes, old_index, direction, increment)
    local adjust_by = direction == "next" and increment or -increment
    local new_index = old_index + adjust_by

    new_index = new_index > #nodes and #nodes or new_index
    new_index = new_index < 1 and 1 or new_index

    return new_index
end

local get_previous_or_next_node = function(nodes, old_index, direction, destination)
    if direction == "in-place" then
        return nodes[old_index]
    end

    local new_index = adjust_index_base_on_direction(nodes, old_index, direction, 1)

    -- skip 1 index if it's the same jsx_element
    local old_jsx_parent = lib_ts.get_jsx_parent_of_bracket(nodes[old_index])
    local new_jsx_parent = lib_ts.get_jsx_parent_of_bracket(nodes[new_index])

    if old_jsx_parent == new_jsx_parent then
        new_index = adjust_index_base_on_direction(nodes, new_index, direction, 1)
    end

    -- switch target to the correct opening / closing tag
    if destination == "next-to" then
        local opening, closing = lib_ts.get_first_and_last_bracket(nodes[new_index], destination)
        local opening_row, closing_row = opening:range(), closing:range()
        if opening_row == closing_row then
            return opening
        end
    end

    return nodes[new_index]
end

M.get_jump_target = function(direction, destination, winnr)
    local opening_brackets = lib_ts.get_all_nodes_matches_query(
        [[
("<" @bracket (#has-ancestor? @bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx"
    )

    if opening_brackets then
        local jsx_parent =
            lib_ts.find_parent(winnr, { "jsx_element", "jsx_self_closing_element", "jsx_fragment" })
        local closest_bracket, closest_index = get_closest_node_to_cursor(opening_brackets, winnr)

        if jsx_parent then
            return get_previous_or_next_node(
                opening_brackets,
                closest_index,
                direction,
                destination
            )
        else
            return closest_bracket
        end
    else
        vim.notify("Buffer has no JSX element", vim.log.levels.INFO)
    end
end

M.jump = function(direction, destination, winnr)
    local bracket_node = M.get_jump_target(direction, destination, winnr)

    if bracket_node then
        local start_row, start_col, _, _ = bracket_node:range()
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
        return bracket_node -- return the target node for highlighting purposes
    end
end

return M
