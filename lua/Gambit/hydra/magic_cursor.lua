local Hydra = require("hydra")
local lib_highlighting = require("Gambit.lib.highlighting")
local lib_magic_cursor = require("Gambit.lib.magic-cursor")
local lib_tag_creation = require("Gambit.lib.tag-creation")

local hint_flower = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠖⠋⠉⠉⠳⡴⠒⠒⠒⠲⠤⢤⣀⠀⠀⠀⠀  
⠀⠀⠀⠀⠀⠀⠀⣠⠊⠀⠀⡴⠚⡩⠟⠓⠒⡖⠲⡄⠀⠀⠈⡆⠀⠀⠀  
⠀⠀⠀⠀⠀⢀⡞⠁⢠⠒⠾⢥⣀⣇⣚⣹⡤⡟⠀⡇⢠⠀⢠⠇⠀⠀⠀  
⠀⠀⠀⠀⠀⢸⣄⣀⠀⡇⠀⠀⠀⠀⠀⢀⡜⠁⣸⢠⠎⣰⣃⠀⠀⠀⠀      _k_ / _j_: prevous / next tag
⠀⠀⠀⠀⠸⡍⠀⠉⠉⠛⠦⣄⠀⢀⡴⣫⠴⠋⢹⡏⡼⠁⠈⠙⢦⡀⠀        _%_
⠀⠀⠀⠀⣀⡽⣄⠀⠀⠀⠀⠈⠙⠻⣎⡁⠀⠀⣸⡾⠀⠀⠀⠀⣀⡹⠂    
⠀⠀⢀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠉⠓⠶⢟⠀⢀⡤⠖⠋⠁⠀⠀    
⠀⠀⠀⠉⠙⠒⠦⡀⠙⠦⣀⠀⠀⠀⠀⠀⠀⢀⣴⡷⠋⠀⠀⠀⠀⠀⠀      _d_: div
⠀⠀⠀⠀⠀⠀⠀⠘⢦⣀⠈⠓⣦⣤⣤⣤⢶⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀      _U_: ul    _l_: li
⠀⢤⣤⣤⡤⠤⠤⠤⠤⣌⡉⠉⠁⠀⠀⢸⢸⠁⡠⠖⠒⠒⢒⣒⡶⣶⠤ 
⠀⠀⠉⠲⣍⠓⠦⣄⠀⠀⠙⣆⠀⠀⠀⡞⡼⡼⢀⣠⠴⠊⢉⡤⠚⠁⠀    
⠀⠀⠀⠀⠈⠳⣄⠈⠙⢦⡀⢸⡀⠀⢰⢣⡧⠷⣯⣤⠤⠚⠉⠀⠀⠀⠀      _u_: undo
⠀⠀⠀⠀⠀⠀⠈⠑⣲⠤⠬⠿⠧⣠⢏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      
⠀⠀⠀⠀⢀⡴⠚⠉⠉⢉⣳⣄⣠⠏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _q_, _<Esc>_: exit
⠀⠀⣠⣴⣟⣒⣋⣉⣉⡭⠟⢡⠏⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⢀⠏⣸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⢠⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠓⠚
]]

--------------------------------------------

local ns = vim.api.nvim_create_namespace("magic_cursor")
local insert_new_tags_inside = false

local toggle_inside_or_outside_opt = function()
    insert_new_tags_inside = not insert_new_tags_inside
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    lib_highlighting.highlight_tag_braces(ns, 0, insert_new_tags_inside)
end

local new_tag = function(opts, namespace)
    opts.count = require("Gambit.lib.vim-utils").get_count()
    opts.inside = insert_new_tags_inside

    lib_tag_creation.create_tag_at_cursor(opts)
    vim.schedule(function()
        if insert_new_tags_inside then
            insert_new_tags_inside = false
        end

        vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
        lib_highlighting.highlight_tag_braces(namespace, 0, insert_new_tags_inside)
    end)
end

local jump = function(direction)
    local count = require("Gambit.lib.vim-utils").get_count()

    for _ = 1, count do
        lib_magic_cursor.jump_to_previous_or_next_tag(direction)
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        lib_highlighting.highlight_tag_braces(ns, 0, insert_new_tags_inside)
    end
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
            lib_highlighting.highlight_tag_braces(ns)
        end,
        on_exit = function()
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        end,
    },
    mode = "n",
    body = "<Leader>f",
    heads = {
        {
            "t",
            function()
                toggle_inside_or_outside_opt()
            end,
            { nowait = true },
        },

        --------------------------------------------

        {
            "d",
            function()
                new_tag({ tag = "div" }, ns)
            end,
            { nowait = true },
        },
        {
            "U",
            function()
                new_tag({ tag = "ul" }, ns)
            end,
            { nowait = true },
        },
        {
            "l",
            function()
                new_tag({ tag = "li" }, ns)
            end,
            { nowait = true },
        },

        --------------------------------------------

        {
            "j",
            function()
                jump("next")
            end,
            { nowait = true },
        },
        {
            "k",
            function()
                jump("previous")
            end,
            { nowait = true },
        },

        --------------------------------------------

        {
            "%",
            function()
                lib_magic_cursor.cycle_between_opening_and_closing_tag()
            end,
            { nowait = true },
        },

        {
            "u",
            function()
                vim.cmd("norm! u")
                vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
                lib_highlighting.highlight_tag_braces(ns)
            end,
            { nowait = true },
        },

        --------------------------------------------

        { "<Esc>", nil, { exit = true, nowait = true } },
        { "q", nil, { exit = true, nowait = true } },
    },
})

-- {{{nvim-execute-on-save}}}
