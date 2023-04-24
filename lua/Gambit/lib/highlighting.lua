---@diagnostic disable: need-check-nil

local M = {}
local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("Gambit.lib.tree-sitter")

M.highlight_tag_indicators = function(namespace)
    local opening_tag_node, closing_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)

    if opening_tag_node then
        ts_utils.highlight_node(opening_tag_node, 0, namespace, "CurSearch")
    end
    if closing_tag_node then
        ts_utils.highlight_node(closing_tag_node, 0, namespace, "CurSearch")
    end
end

local get_children_nodes = function(parent)
    local nodes = {}
    for node in parent:iter_children() do
        table.insert(nodes, node)
    end
    return nodes
end

M.highlight_tag_braces = function(namespace, bufnr, insert_new_tags_inside)
    namespace = namespace or 0
    bufnr = bufnr or 0
    insert_new_tags_inside = insert_new_tags_inside or false

    local first_extmark_content, second_extmark_content = "<", ">"
    local hl_group = "@lsp.type.method"

    local opening_brace, closing_brace
    local opening_tag_node, closing_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)

    if not opening_tag_node then
        return
    end

    if insert_new_tags_inside and closing_tag_node then
        first_extmark_content, second_extmark_content = ">", "<"
        hl_group = "DiffText"

        local jsx_element = opening_tag_node:parent():parent()

        local closings = lib_ts.get_all_nodes_matches_query('(">" @brace)', "tsx", jsx_element)
        opening_brace = closings[1]

        local opennings = lib_ts.get_all_nodes_matches_query('("<" @brace)', "tsx", jsx_element)
        closing_brace = opennings[#opennings]
    else
        if opening_tag_node:parent():type() == "jsx_self_closing_element" then
            local children = get_children_nodes(opening_tag_node:parent())
            opening_brace, closing_brace = children[1], children[#children]
        else
            local opening_tag_children = get_children_nodes(opening_tag_node:parent())
            opening_brace = opening_tag_children[1]

            local closing_tag_children = get_children_nodes(closing_tag_node:parent())
            closing_brace = closing_tag_children[#closing_tag_children]
        end
    end

    if opening_brace then
        local start_row, start_col, _, _ = opening_brace:range()
        vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
            virt_text = { { first_extmark_content, hl_group } },
            virt_text_pos = "overlay",
            priority = 1000,
        })
    end
    if closing_brace then
        local _, _, end_row, end_col = closing_brace:range()
        vim.api.nvim_buf_set_extmark(0, namespace, end_row, end_col - 1, {
            virt_text = { { second_extmark_content, hl_group } },
            virt_text_pos = "overlay",
            priority = 1000,
        })
    end

    return opening_tag_node
end

return M
