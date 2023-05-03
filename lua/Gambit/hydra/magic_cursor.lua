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
⠀⠀⠀⠀⣀⡽⣄⠀⠀⠀⠀⠈⠙⠻⣎⡁⠀⠀⣸⡾⠀⠀⠀⠀⣀⡹⠂      _<C-S-P>_
⠀⠀⢀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠉⠓⠶⢟⠀⢀⡤⠖⠋⠁⠀⠀    
⠀⠀⠀⠉⠙⠒⠦⡀⠙⠦⣀⠀⠀⠀⠀⠀⠀⢀⣴⡷⠋⠀⠀⠀⠀⠀⠀      _d_: div
⠀⠀⠀⠀⠀⠀⠀⠘⢦⣀⠈⠓⣦⣤⣤⣤⢶⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀      _U_: ul    _l_: li
⠀⢤⣤⣤⡤⠤⠤⠤⠤⣌⡉⠉⠁⠀⠀⢸⢸⠁⡠⠖⠒⠒⢒⣒⡶⣶⠤ 
⠀⠀⠉⠲⣍⠓⠦⣄⠀⠀⠙⣆⠀⠀⠀⡞⡼⡼⢀⣠⠴⠊⢉⡤⠚⠁⠀    
⠀⠀⠀⠀⠈⠳⣄⠈⠙⢦⡀⢸⡀⠀⢰⢣⡧⠷⣯⣤⠤⠚⠉⠀⠀⠀⠀      _i_: change in tag
⠀⠀⠀⠀⠀⠀⠈⠑⣲⠤⠬⠿⠧⣠⢏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀      _o_: toggle insert inside
⠀⠀⠀⠀⢀⡴⠚⠉⠉⢉⣳⣄⣠⠏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    
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

local jump_and_highlight_sibling = function(direction, hl_group)
    local count = require("Gambit.lib.vim-utils").get_count()

    for _ = 1, count do
        local sibling = cosmic_cursor.jump_to_jsx_sibling(0, direction)
        if sibling then
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
            cosmic_rays.highlight_braces(sibling, destination, ns, 0, hl_group or "DiffText")
        end
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

local previous_add_tag_args
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

    GAMBIT_PREVIOUS_ACTION = "add-tag"
    previous_add_tag_args = { tag, enter }
end

--------------------------------------------

REMAP({ "n", "x", "i" }, "<Plug>[R1 K, R1 L] --up<Plug>", "<Nop>")
REMAP({ "n", "x", "i" }, "<Plug>R1 B --down<Plug>", "<Nop>")

local pms_menu = require("Gambit.ui.pms_menu")
local colors_menu = require("Gambit.ui.colors_menu")

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
            "fl",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "f" }, classes = { "flex" } },
                    { keymaps = { "r" }, classes = { "flex", "flex-row" } },
                })
            end,
            { nowait = true },
        },

        {
            "a",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "i" }, classes = { "items-center" } },
                    { keymaps = { "j" }, classes = { "justify-center" } },
                    { keymaps = { "b" }, classes = { "justify-between" } },
                    { keymaps = { "cb" }, classes = { "content-between" } },
                    { keymaps = { "cc" }, classes = { "items-center", "justify-center" } },
                })
            end,
            { nowait = true },
        },

        {
            "z",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "x" }, classes = { "text-xs" } },
                    { keymaps = { "m" }, classes = { "text-sm" } },
                    { keymaps = { "b" }, classes = { "text-base" } },
                    { keymaps = { "l" }, classes = { "text-lg" } },
                    { keymaps = { "q", "1" }, classes = { "text-xl" } },
                    { keymaps = { "w", "2" }, classes = { "text-2xl" } },
                    { keymaps = { "e", "3" }, classes = { "text-3xl" } },
                    { keymaps = { "r", "4" }, classes = { "text-4xl" } },
                    { keymaps = { "t", "5" }, classes = { "text-5xl" } },
                    { keymaps = { "a", "6" }, classes = { "text-6xl" } },
                    { keymaps = { "s", "7" }, classes = { "text-7xl" } },
                    { keymaps = { "d", "8" }, classes = { "text-8xl" } },
                    { keymaps = { "f", "9" }, classes = { "text-9xl" } },
                }, "after")
            end,
            { nowait = true },
        },

        {
            "<C-a>",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "h" }, classes = { "text-left" } },
                    { keymaps = { "l" }, classes = { "text-right" } },
                    { keymaps = { "k" }, classes = { "text-center" } },
                    { keymaps = { "j" }, classes = { "text-justify" } },
                }, "after")
            end,
            { nowait = true },
        },

        ------------------------------------------ Repeat

        {
            ".",
            function()
                if GAMBIT_PREVIOUS_ACTION then
                    if GAMBIT_PREVIOUS_ACTION == "changing-classes" then
                        pms_menu.apply_previous_action()
                    elseif GAMBIT_PREVIOUS_ACTION == "add-tag" then
                        new_tag(unpack(previous_add_tag_args))
                    end
                end
            end,
            { nowait = true },
        },

        ------------------------------------------ colors

        {
            "t",
            function()
                colors_menu.change_text_color()
            end,
            { nowait = true },
        },

        {
            "b",
            function()
                colors_menu.change_background_color()
            end,
            { nowait = true },
        },

        ------------------------------------------ paddings
        {
            "P",
            function()
                pms_menu.show_paddings_menu("")
            end,
            { nowait = true },
        },
        {
            "<C-S-P>",
            function()
                pms_menu.show_paddings_menu("", "all")
            end,
            { nowait = true },
        },

        ----- padding x and y
        {
            "py",
            function()
                pms_menu.show_paddings_menu("y")
            end,
            { nowait = true },
        },
        {
            "pY",
            function()
                pms_menu.show_paddings_menu("x", { "t", "b" })
            end,
            { nowait = true },
        },
        {
            "px",
            function()
                pms_menu.show_paddings_menu("x")
            end,
            { nowait = true },
        },
        {
            "pX",
            function()
                pms_menu.show_paddings_menu("x", { "l", "r" })
            end,
            { nowait = true },
        },

        {
            "p<C-y>",
            function()
                pms_menu.show_paddings_menu("y", "all")
            end,
            { nowait = true },
        },
        {
            "p<C-x>",
            function()
                pms_menu.show_paddings_menu("x", "all")
            end,
            { nowait = true },
        },

        ----- padding t,b,l,r
        {
            "pl",
            function()
                pms_menu.show_paddings_menu("l")
            end,
            { nowait = true },
        },
        {
            "pr",
            function()
                pms_menu.show_paddings_menu("r")
            end,
            { nowait = true },
        },
        {
            "pt",
            function()
                pms_menu.show_paddings_menu("t")
            end,
            { nowait = true },
        },
        {
            "pb",
            function()
                pms_menu.show_paddings_menu("b")
            end,
            { nowait = true },
        },

        ------------------------------------------ margins
        {
            "M",
            function()
                pms_menu.show_margins_menu("")
            end,
            { nowait = true },
        },
        {
            "<C-S-M>",
            function()
                pms_menu.show_margins_menu("", "all")
            end,
            { nowait = true },
        },

        ----- padding x and y
        {
            "my",
            function()
                pms_menu.show_margins_menu("y")
            end,
            { nowait = true },
        },
        {
            "mx",
            function()
                pms_menu.show_margins_menu("x")
            end,
            { nowait = true },
        },

        ----- padding t,b,l,r
        {
            "ml",
            function()
                pms_menu.show_margins_menu("l")
            end,
            { nowait = true },
        },
        {
            "mr",
            function()
                pms_menu.show_margins_menu("r")
            end,
            { nowait = true },
        },
        {
            "mt",
            function()
                pms_menu.show_margins_menu("t")
            end,
            { nowait = true },
        },
        {
            "mb",
            function()
                pms_menu.show_margins_menu("b")
            end,
            { nowait = true },
        },

        ------------------------------------------ spacing
        {
            "sx",
            function()
                pms_menu.show_spacing_menu("x")
            end,
            { nowait = true },
        },
        {
            "sy",
            function()
                pms_menu.show_spacing_menu("y")
            end,
            { nowait = true },
        },

        {
            "sX",
            function()
                pms_menu.show_spacing_menu("x", "all")
            end,
            { nowait = true },
        },
        {
            "sY",
            function()
                pms_menu.show_spacing_menu("y", "all")
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

        -------------------------------------------- Jumping to Previous / Next JSX Sibling

        {
            "<C-j>",
            function()
                jump_and_highlight_sibling("next")
            end,
            { nowait = true },
        },
        {
            "<C-k>",
            function()
                jump_and_highlight_sibling("previous")
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
