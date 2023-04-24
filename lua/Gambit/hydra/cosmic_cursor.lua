local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

local function get_closest_jsx_node_to_cursor(nodes)
    local current_cursor_line = unpack(vim.api.nvim_win_get_cursor(0))
    local closest_node, closest_difference = nil, math.huge

    for _, node in ipairs(nodes) do
        local start_row = node:range()
        local difference = math.abs(start_row - current_cursor_line)
        if difference < closest_difference then
            closest_node, closest_difference = node, difference
        else
            break
        end
    end

    return closest_node
end

M.find_jump_target = function(direction, winnr)
    local all_brackets = lib_ts.get_all_nodes_matches_query(
        [[
("<" @left_bracket (#has-ancestor? @left_bracket jsx_element jsx_self_closing_element jsx_fragment))
(">" @right_bracket (#has-ancestor? @right_bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx"
    )

    if all_brackets then
        local cursor_inside_jsx =
            M.find_parent(winnr, { "jsx_element", "jsx_self_closing_element", "jsx_fragment" })

        if cursor_inside_jsx then
            -- TODO:
        else
            return get_closest_jsx_node_to_cursor(all_brackets)
        end
    else
        vim.notify("Buffer has no JSX element", vim.log.levels.INFO)
    end
end

return M
