local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

M.to_be_determined = function(direction, winnr)
    local all_brackets = lib_ts.get_all_nodes_matches_query(
        [[
("<" @left_bracket (#has-ancestor? @left_bracket jsx_element jsx_self_closing_element jsx_fragment))
(">" @right_bracket (#has-ancestor? @right_bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx"
    )

    local cursor_inside_jsx =
        M.find_parent(winnr, { "jsx_element", "jsx_self_closing_element", "jsx_fragment" })

    if cursor_inside_jsx then
        -- TODO:
    else
        if all_brackets then
            -- TODO: jump to the closest jsx_element / jsx_fragment to the cursor
        else
            vim.notify("Buffer has no JSX element", vim.log.levels.INFO)
        end
    end
end

return M
