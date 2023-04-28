local Hydra = require("hydra")

local cosmic_cursor = require("Gambit.lib.cosmic-cursor")
local cosmic_rays = require("Gambit.lib.cosmic-rays")
local cosmic_creation = require("Gambit.lib.cosmic-creation")
local classes_replacer = require("Gambit.lib.class-replacer")

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

local new_tag = function(tag, enter)
    local count = require("Gambit.lib.vim-utils").get_count()
    local added_new_lines = cosmic_creation.create_tag_at_cursor(tag, destination, count)

    -- update cursor position to the newly created tag
    if added_new_lines then
        vim.cmd("norm! k")
    else
        local jump_cmd = "norm! " .. count .. "j"
        vim.cmd(jump_cmd)
    end
    vim.cmd("norm! ^")

    -- update destination for future tags base on `enter` argument
    destination = enter and "inside" or "next-to"

    -- update the highlighting
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    local target_node = cosmic_cursor.get_jump_target("in-place", destination, 0)
    cosmic_rays.highlight_braces(target_node, destination, ns, 0, "DiffText")
end

--------------------------------------------

REMAP({ "n", "x", "i" }, "<Plug>[R1 K, R1 L] --up<Plug>", "<Nop>")
REMAP({ "n", "x", "i" }, "<Plug>R1 B --down<Plug>", "<Nop>")

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
    body = "<Plug>R1 B --down<Plug>",
    heads = {
        -------------------------------------------- CIT and Toggle Destination

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

        -------------------------------------------- Replacing Classes

        {
            "c",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu()
            end,
            { nowait = true },
        },

        ----- padding
        {
            "P",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("")
            end,
            { nowait = true },
        },
        {
            "<C-S-P>",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("", "all")
            end,
            { nowait = true },
        },

        ----- padding x and y
        {
            "py",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("y")
            end,
            { nowait = true },
        },
        {
            "px",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("x")
            end,
            { nowait = true },
        },

        ----- padding t,b,l,r
        {
            "pl",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("l")
            end,
            { nowait = true },
        },
        {
            "pr",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("r")
            end,
            { nowait = true },
        },
        {
            "pt",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("t")
            end,
            { nowait = true },
        },
        {
            "pb",
            function()
                require("Gambit.ui.replace_paddings_menu").show_menu("b")
            end,
            { nowait = true },
        },

        {
            "<Plug>[R1 K, R1 L] --up<Plug>",
            function()
                classes_replacer.change_tailwind_colors(0, 0, { text = "text-gray-800" })
            end,
            { nowait = true },
        },

        -------------------------------------------- Adding Tags

        {
            "d",
            function()
                new_tag("div", true)
            end,
            { nowait = true },
        },
        {
            "U",
            function()
                new_tag("ul", true)
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

        -------------------------------------------- Jumping to Previous / Next Tag

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

        -------------------------------------------- Undo with updated highlighting

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
