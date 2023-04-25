local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("Gambit.lib.tree-sitter")

local get_correct_parent_node = function(node)
    local parent = node:parent()

    if parent:type() == "jsx_self_closing_element" or parent:type() == "jsx_fragment" then
        return parent
    end

    return parent:parent()
end

M.highlight_braces = function(node, destination, namespace, bufnr, hl_group)
    node = get_correct_parent_node(node)

    local opening_brackets = lib_ts.get_all_nodes_matches_query(
        [[
("<" @bracket (#has-ancestor? @bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx",
        node
    )
    local closing_brackets = lib_ts.get_all_nodes_matches_query(
        [[
(">" @bracket (#has-ancestor? @bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx",
        node
    )

    if #opening_brackets == 0 or #closing_brackets == 0 then
        return
    end

    local opening, closing
    if destination == "next-to" then
        opening = opening_brackets[1]
        closing = closing_brackets[#closing_brackets]
    elseif destination == "inside" then
        opening = closing_brackets[1]
        closing = opening_brackets[#opening_brackets]
    end

    ts_utils.highlight_node(opening, bufnr, namespace, hl_group)
    ts_utils.highlight_node(closing, bufnr, namespace, hl_group)
end

return M
