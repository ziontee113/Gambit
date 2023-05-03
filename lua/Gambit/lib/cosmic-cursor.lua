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

local get_previous_or_next_node = function(opening_brackets, old_index, direction, destination)
    if direction == "in-place" then
        return opening_brackets[old_index]
    end

    local new_index = adjust_index_base_on_direction(opening_brackets, old_index, direction, 1)

    -- skip 1 index if it's the same jsx_element
    local old_jsx_parent = lib_ts.get_jsx_parent_of_bracket(opening_brackets[old_index])
    local new_jsx_parent = lib_ts.get_jsx_parent_of_bracket(opening_brackets[new_index])

    if old_jsx_parent == new_jsx_parent then
        new_index = adjust_index_base_on_direction(opening_brackets, new_index, direction, 1)
    end

    -- switch target to the correct opening / closing tag
    if destination == "next-to" then
        local opening, closing =
            lib_ts.get_first_and_last_bracket(opening_brackets[new_index], destination)
        local opening_row, closing_row = opening:range(), closing:range()
        if opening_row == closing_row then
            return opening
        end
    end

    return opening_brackets[new_index]
end

local find_correct_opening_bracket_of_node = function(node, winnr)
    local opening_brackets = lib_ts.get_all_nodes_matches_query([[ ("<" @bracket) ]], "tsx", node)

    if node:type() ~= "jsx_fragment" then
        return opening_brackets[1]
    else
        local cursor_row = unpack(vim.api.nvim_win_get_cursor(winnr))
        cursor_row = cursor_row - 1

        local first_bracket = opening_brackets[1]
        local last_bracket = opening_brackets[#opening_brackets]

        if first_bracket:range() == cursor_row then
            return first_bracket
        else
            return last_bracket
        end
    end
end

local get_first_match_index = function(nodes, node_to_match)
    for i, node in ipairs(nodes) do
        if node == node_to_match then
            return i
        end
    end
end

M.get_jump_target = function(direction, destination, winnr)
    local opening_brackets = lib_ts.get_all_nodes_matches_query(
        [[
("<" @bracket (#has-ancestor? @bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx"
    )

    if opening_brackets then
        local jsx_parent = lib_ts.find_parent(winnr, {
            "jsx_opening_element",
            "jsx_closing_element",
            "jsx_self_closing_element",
            "jsx_fragment",
        })

        if jsx_parent then
            local bracket = find_correct_opening_bracket_of_node(jsx_parent, winnr)
            local bracket_index = get_first_match_index(opening_brackets, bracket)

            return get_previous_or_next_node(
                opening_brackets,
                bracket_index,
                direction,
                destination
            )
        else
            return get_closest_node_to_cursor(opening_brackets, winnr)
        end
    else
        vim.notify("Buffer has no JSX element", vim.log.levels.INFO)
    end
end

local set_cursor_to_node = function(node)
    local start_row, start_col, _, _ = node:range()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

M.jump = function(direction, destination, winnr)
    local bracket_node = M.get_jump_target(direction, destination, winnr)
    if bracket_node then
        set_cursor_to_node(bracket_node)
        return bracket_node -- return the target node for highlighting purposes
    end
end

local find_jsx_sibling = function(jsx_element, direction)
    local sibling = jsx_element

    while sibling do
        if direction == "next" then
            sibling = sibling:next_named_sibling()
        else
            sibling = sibling:prev_named_sibling()
        end
        if not sibling then
            return
        end
        if sibling:type() == "jsx_element" or sibling:type() == "jsx_self_closing_element" then
            return sibling
        end
    end
end

M.jump_to_jsx_relative = function(winnr, direction)
    local jsx_element = lib_ts.find_parent(winnr, { "jsx_element", "jsx_self_closing_element" })
    local parent = jsx_element:parent()

    if parent:type() == "jsx_element" or parent:type() == "jsx_fragment" then
        if direction == "parent" then
            set_cursor_to_node(parent)
            return parent
        end

        local sibling = find_jsx_sibling(jsx_element, direction)
        if sibling then
            set_cursor_to_node(sibling)
            return sibling
        end
    end
end

return M
