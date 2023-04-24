---@diagnostic disable: need-check-nil

local lib_ts = require("Gambit.lib.tree-sitter")

local M = {}

M.jump_to_previous_or_next_tag = function(direction)
    local opening_tag_node, closing_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)
    local og_cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

    local queried_nodes = lib_ts.get_all_nodes_matches_query(
        [[
(jsx_opening_element name: (identifier) @tag)
(jsx_closing_element name: (identifier) @tag)
(jsx_self_closing_element name: (identifier) @tag)
    ]],
        "tsx"
    )
    local match_index = 1

    if opening_tag_node then
        local og_parent_node
        if opening_tag_node:parent():type() ~= "jsx_self_closing_element" then
            og_parent_node = opening_tag_node:parent():parent()
        else
            og_parent_node = opening_tag_node:parent()
        end

        for i, node in ipairs(queried_nodes) do
            if (node == opening_tag_node) or (node == closing_tag_node) then
                local start_row, _, _, _ = node:range()

                if
                    node:parent():type() == "jsx_self_closing_element"
                    or start_row == og_cursor_line
                then
                    match_index = i
                    break
                end
            end
        end

        local addons = direction == "next" and 1 or -1
        match_index = match_index + addons

        if
            queried_nodes[match_index]
            and queried_nodes[match_index]:parent():type() ~= "jsx_self_closing_element"
            and queried_nodes[match_index]:parent():parent() == og_parent_node
        then
            local opening_node, closing_node = lib_ts.get_opening_and_closing_tag_nodes(
                0,
                queried_nodes[match_index]:parent():parent()
            )

            local opening_row = opening_node:range()
            local closing_row = closing_node:range()

            if opening_row == closing_row then
                match_index = match_index + addons
            end
        end

        if match_index < 1 then
            match_index = 1
        elseif match_index > #queried_nodes then
            match_index = #queried_nodes
        end
    else
        if direction == "next" then
            match_index = 1
        else
            match_index = #queried_nodes
        end
    end

    local target_node = queried_nodes[match_index]
    local start_row, start_col, _, _ = target_node:range()

    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd("norm! ^")
end

M.cycle_between_opening_and_closing_tag = function()
    local opening_tag_node, closing_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)
    local opening_row, opening_col = opening_tag_node:range()
    local closing_row, _ = closing_tag_node:range()

    local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

    if opening_row == closing_row then
        if cursor_col > opening_col then
            vim.cmd("norm! ^")
        else
            vim.cmd("norm! $")
        end
        return
    end

    if
        (cursor_line == closing_row + 1)
        or (cursor_line ~= opening_row + 1 and cursor_line ~= closing_row + 1)
    then
        vim.api.nvim_win_set_cursor(0, { opening_row + 1, 0 })
        vim.cmd("norm! ^")
    else
        vim.api.nvim_win_set_cursor(0, { closing_row + 1, 0 })
        vim.cmd("norm! $")
    end
end

return M
