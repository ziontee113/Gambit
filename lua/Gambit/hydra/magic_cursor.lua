local Hydra = require("hydra")

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("Gambit.lib.tree-sitter")

local hint_flower = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠖⠋⠉⠉⠳⡴⠒⠒⠒⠲⠤⢤⣀⠀⠀⠀⠀  
⠀⠀⠀⠀⠀⠀⠀⣠⠊⠀⠀⡴⠚⡩⠟⠓⠒⡖⠲⡄⠀⠀⠈⡆⠀⠀⠀  
⠀⠀⠀⠀⠀⢀⡞⠁⢠⠒⠾⢥⣀⣇⣚⣹⡤⡟⠀⡇⢠⠀⢠⠇⠀⠀⠀  
⠀⠀⠀⠀⠀⢸⣄⣀⠀⡇⠀⠀⠀⠀⠀⢀⡜⠁⣸⢠⠎⣰⣃⠀⠀⠀⠀      _<C-j>_ <C-k>
⠀⠀⠀⠀⠸⡍⠀⠉⠉⠛⠦⣄⠀⢀⡴⣫⠴⠋⢹⡏⡼⠁⠈⠙⢦⡀⠀    
⠀⠀⠀⠀⣀⡽⣄⠀⠀⠀⠀⠈⠙⠻⣎⡁⠀⠀⣸⡾⠀⠀⠀⠀⣀⡹⠂    
⠀⠀⢀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠉⠓⠶⢟⠀⢀⡤⠖⠋⠁⠀⠀    
⠀⠀⠀⠉⠙⠒⠦⡀⠙⠦⣀⠀⠀⠀⠀⠀⠀⢀⣴⡷⠋⠀⠀⠀⠀⠀⠀    
⠀⠀⠀⠀⠀⠀⠀⠘⢦⣀⠈⠓⣦⣤⣤⣤⢶⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀    
⠀⢤⣤⣤⡤⠤⠤⠤⠤⣌⡉⠉⠁⠀⠀⢸⢸⠁⡠⠖⠒⠒⢒⣒⡶⣶⠤    
⠀⠀⠉⠲⣍⠓⠦⣄⠀⠀⠙⣆⠀⠀⠀⡞⡼⡼⢀⣠⠴⠊⢉⡤⠚⠁⠀    
⠀⠀⠀⠀⠈⠳⣄⠈⠙⢦⡀⢸⡀⠀⢰⢣⡧⠷⣯⣤⠤⠚⠉⠀⠀⠀⠀    
⠀⠀⠀⠀⠀⠀⠈⠑⣲⠤⠬⠿⠧⣠⢏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                                          
⠀⠀⠀⠀⢀⡴⠚⠉⠉⢉⣳⣄⣠⠏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _q_ _<Esc>_  
⠀⠀⣠⣴⣟⣒⣋⣉⣉⡭⠟⢡⠏⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⢀⠏⣸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⢠⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠓⠚
]]

--------------------------------------------

local ns = vim.api.nvim_create_namespace("magic_cursor")

-- TODO: given a TSX buffer:
-- on Hydra initiation, highlight the opening and closing tags.
-- on pressing `j / k`, or `<C-j> / <C-k>`: update those tags highlighting.
--> we can do this by first jump the cursor to
--- the previous / next`{ "jsx_element", "jsx_self_closing_element" }`.
---> then we can call `highlight_tag_indicators()` after that.

--? But how do we jump like that?
--- My first instinct is to get the current opening tag first,
--- using `get_opening_and_closing_tag_nodes()`,
--- then loop through a "tag query results", find the node that matches the tag node,
--- then find the index from there.
--- from that index, we clear the old highlight and show the new highlight.

local highlight_tag_indicators = function()
    local opening_tag_node, closing_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)

    if opening_tag_node then
        ts_utils.highlight_node(opening_tag_node, 0, ns, "CurSearch")
    end
    if closing_tag_node then
        ts_utils.highlight_node(closing_tag_node, 0, ns, "CurSearch")
    end
end

local jump_to_previous_or_next_tag = function(direction)
    local opening_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)

    local all_opening_tag_nodes = lib_ts.get_all_nodes_matches_query(
        [[
(jsx_opening_element name: (identifier) @tag)
(jsx_self_closing_element name: (identifier) @tag)
    ]],
        "tsx"
    )

    local match_index = 1
    for i, node in ipairs(all_opening_tag_nodes) do
        if node == opening_tag_node then
            match_index = i
            break
        end
    end

    if direction == "next" then
        match_index = match_index + 1
    elseif direction == "previous" then
        match_index = match_index - 1
    end

    if match_index < 1 or match_index > #all_opening_tag_nodes then
        match_index = 1
    end

    local target_node = all_opening_tag_nodes[match_index]
    local start_row, start_col, _, _ = target_node:range()

    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    highlight_tag_indicators()
end

--------------------------------------------

Hydra({
    name = "Telescope",
    hint = hint_flower,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-right",
            border = "rounded",
        },
        on_enter = function()
            highlight_tag_indicators()
        end,
        on_exit = function()
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        end,
    },
    mode = "n",
    body = "<Leader>f",
    heads = {
        {
            "<C-j>",
            function()
                jump_to_previous_or_next_tag("next")
            end,
            { nowait = true },
        },
        {
            "<C-k>",
            function()
                jump_to_previous_or_next_tag("previous")
            end,
            { nowait = true },
        },
        { "<Esc>", nil, { exit = true, nowait = true } },
        { "q", nil, { exit = true, nowait = true } },
    },
})

-- {{{nvim-execute-on-save}}}
