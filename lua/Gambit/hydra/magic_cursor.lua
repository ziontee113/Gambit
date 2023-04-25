local Hydra = require("hydra")

local cosmic_cursor = require("Gambit.lib.cosmic-cursor")
local cosmic_rays = require("Gambit.lib.cosmic-rays")
local cosmic_creation = require("Gambit.lib.cosmic-creation")

local hint_flower = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠖⠋⠉⠉⠳⡴⠒⠒⠒⠲⠤⢤⣀⠀⠀⠀⠀  
⠀⠀⠀⠀⠀⠀⠀⣠⠊⠀⠀⡴⠚⡩⠟⠓⠒⡖⠲⡄⠀⠀⠈⡆⠀⠀⠀  
⠀⠀⠀⠀⠀⢀⡞⠁⢠⠒⠾⢥⣀⣇⣚⣹⡤⡟⠀⡇⢠⠀⢠⠇⠀⠀⠀  
⠀⠀⠀⠀⠀⢸⣄⣀⠀⡇⠀⠀⠀⠀⠀⢀⡜⠁⣸⢠⠎⣰⣃⠀⠀⠀⠀      _k_ / _j_: prevous / next tag
⠀⠀⠀⠀⠸⡍⠀⠉⠉⠛⠦⣄⠀⢀⡴⣫⠴⠋⢹⡏⡼⠁⠈⠙⢦⡀⠀     
⠀⠀⠀⠀⣀⡽⣄⠀⠀⠀⠀⠈⠙⠻⣎⡁⠀⠀⣸⡾⠀⠀⠀⠀⣀⡹⠂    
⠀⠀⢀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠉⠓⠶⢟⠀⢀⡤⠖⠋⠁⠀⠀    
⠀⠀⠀⠉⠙⠒⠦⡀⠙⠦⣀⠀⠀⠀⠀⠀⠀⢀⣴⡷⠋⠀⠀⠀⠀⠀⠀      _d_: div
⠀⠀⠀⠀⠀⠀⠀⠘⢦⣀⠈⠓⣦⣤⣤⣤⢶⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀      _U_: ul    _l_: li
⠀⢤⣤⣤⡤⠤⠤⠤⠤⣌⡉⠉⠁⠀⠀⢸⢸⠁⡠⠖⠒⠒⢒⣒⡶⣶⠤ 
⠀⠀⠉⠲⣍⠓⠦⣄⠀⠀⠙⣆⠀⠀⠀⡞⡼⡼⢀⣠⠴⠊⢉⡤⠚⠁⠀    
⠀⠀⠀⠀⠈⠳⣄⠈⠙⢦⡀⢸⡀⠀⢰⢣⡧⠷⣯⣤⠤⠚⠉⠀⠀⠀⠀      _i_: change in tag
⠀⠀⠀⠀⠀⠀⠈⠑⣲⠤⠬⠿⠧⣠⢏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _o_: toggle insert inside
⠀⠀⠀⠀⢀⡴⠚⠉⠉⢉⣳⣄⣠⠏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _c_: change class presets 
⠀⠀⣠⣴⣟⣒⣋⣉⣉⡭⠟⢡⠏⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _u_: undo          
⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⢀⠏⣸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                         
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⢠⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _q_, _<Esc>_: exit 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠓⠚
]]

--------------------------------------------

local ns = vim.api.nvim_create_namespace("magic_cursor")
local destination = "next-to"

local jump = function(direction, hl_group)
    local count = require("Gambit.lib.vim-utils").get_count()

    for _ = 1, count do
        local target_node = cosmic_cursor.jump(direction, destination, 0)
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        cosmic_rays.highlight_braces(target_node, destination, ns, 0, hl_group or "DiffText")
    end
end

local toggle_inside_or_outside_opt = function()
    if destination == "next-to" then
        destination = "inside"
    else
        destination = "next-to"
    end

    jump("previous")
    jump("next")
end

local new_tag = function(tag)
    local count = require("Gambit.lib.vim-utils").get_count()
    cosmic_creation.create_tag_at_cursor(tag, destination, count)
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
            jump("in-place")
        end,
        on_exit = function()
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        end,
    },
    mode = "n",
    body = "<Leader>f",
    heads = {
        {
            "o",
            function()
                toggle_inside_or_outside_opt()
            end,
            { nowait = true },
        },

        {
            "i",
            function()
                vim.cmd("norm! cit")
                vim.cmd("startinsert")
                vim.api.nvim_input("<Right>")
            end,
            { nowait = true },
        },

        {
            "c",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu()
            end,
            { nowait = true },
        },

        --------------------------------------------

        {
            "d",
            function()
                new_tag("div")
            end,
            { nowait = true },
        },
        {
            "U",
            function()
                new_tag("ul")
            end,
            { nowait = true },
        },
        {
            "l",
            function()
                new_tag("li")
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
            "u",
            function()
                vim.cmd("norm! u")
                vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
                jump("in-place")
            end,
            { nowait = true },
        },

        --------------------------------------------

        { "<Esc>", nil, { exit = true, nowait = true } },
        { "q", nil, { exit = true, nowait = true } },
    },
})

-- {{{nvim-execute-on-save}}}
