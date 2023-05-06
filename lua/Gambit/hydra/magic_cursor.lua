local Hydra = require("hydra")

local cosmic_cursor = require("Gambit.lib.cosmic-cursor")
local cosmic_rays = require("Gambit.lib.cosmic-rays")
local cosmic_creation = require("Gambit.lib.cosmic-creation")
local lua_patterns = require("Gambit.lua_patterns")

local hints = [[
move: _k_ / _j_ sibling: _<C-k>_ / _<C-j>_ parent: _<C-h>_

tags:        _d_ / _U_ / _l_ / _I_

paddings:   _px_ _py_ / _pX_ _pY_ / _p<C-x>_ _p<C-y>_
            _pt_ _pb_ _pl_ _pr_
            _P_ / _<C-S-P>_
                            
margins:    _mx_ _my_ / _mt_ _mb_ _ml_ _mr_ 
            _M_ / _<C-S-M>_ 

spacing:    _sx_ _sy_ _sX_ _sY_

_i_: change / _o_: destination

_h_: content _sr_: src

_a_: align _fl_: flex _T_: custom presets

_t_: text-color _b_: background-color
_z_: font-size  _fw_: font-weight
_fs_:font-style _td_: text-decoration _<C-a>_: text-align
_O_: opacity

_._: repeat _u_: undo _q_, _<Esc>_: exit 
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
        local sibling = cosmic_cursor.jump_to_jsx_relative(0, direction)
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

REMAP({ "n", "x", "i" }, "<Plug>R1 B --down<Plug>", "<Nop>")

local pms_menu = require("Gambit.ui.pms_menu")
local colors_menu = require("Gambit.ui.colors_menu")

PSEUDO_CLASSES = ""
local indicator = require("Gambit.ui.state_indicator")
local indicator_popup

local mixer_ui = require("Gambit.ui.pseudo_alias_mixer")

Hydra({
    name = "Telescope",
    hint = hints,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-right",
            border = "rounded",
        },
        on_enter = function()
            jump("in-place")

            PSEUDO_CLASSES = ""
            indicator_popup = indicator.initiate()
        end,
        on_exit = function()
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

            if indicator_popup then
                indicator_popup:unmount()
            end
        end,
    },
    mode = "n",
    body = "<Plug>R1 B --down<Plug>",
    heads = {
        {
            "<Tab>",
            function()
                mixer_ui.show(indicator_popup)
            end,
            { nowait = true },
        },

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
            "h",
            function()
                require("Gambit.ui.text_content_menu").replace_content("contents.txt")
            end,
            { nowait = true },
        },
        {
            "sr",
            function()
                require("Gambit.ui.image_src_menu").replace_img_src()
            end,
            { nowait = true },
        },

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
            "fw",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "t", "1" }, classes = { "font-thin" } },
                    { keymaps = { "e", "2" }, classes = { "font-extralight" } },
                    { keymaps = { "l", "3" }, classes = { "font-light" } },
                    { keymaps = { "n", "4" }, classes = { "font-normal" } },
                    { keymaps = { "m", "5" }, classes = { "font-medium" } },
                    { keymaps = { "s", "6" }, classes = { "font-semibold" } },
                    { keymaps = { "b", "7" }, classes = { "font-bold" } },
                    { keymaps = { "E", "8" }, classes = { "font-extrabold" } },
                    { keymaps = { "B", "9" }, classes = { "font-black" } },
                })
            end,
            { nowait = true },
        },

        {
            "td",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "u", "U" }, classes = { "underline" } },
                    { keymaps = { "o", "O" }, classes = { "overline" } },
                    { keymaps = { "l", "L" }, classes = { "line-through" } },
                    { keymaps = { "n", "N" }, classes = { "no-underline" } },
                })
            end,
            { nowait = true },
        },

        -- testing replace_classes_menu w/ negatives
        {
            "T",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu(
                    {
                        { keymaps = { "0" }, classes = {}, hidden = true },
                        { keymaps = { "a" }, classes = { "font-bold", "text-2xl" } },
                    },
                    "after",
                    {
                        lua_patterns.font_weight,
                        lua_patterns.text_decoration,
                        lua_patterns.font_size,
                        lua_patterns.font_style,
                    }
                )
            end,
            { nowait = true },
        },

        {
            "fs",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "i" }, classes = { "italic" } },
                    { keymaps = { "n" }, classes = { "not-italic" } },
                }, "after")
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

        {
            "O",
            function()
                require("Gambit.ui.replace_classes_menu").show_menu({
                    { keymaps = { "0" }, classes = {}, hidden = true },
                    { keymaps = { "n" }, classes = { "opacity-0" } },
                    { keymaps = { "q" }, classes = { "opacity-5" } },
                    { keymaps = { "w" }, classes = { "opacity-10" } },
                    { keymaps = { "e" }, classes = { "opacity-20" } },
                    { keymaps = { "r" }, classes = { "opacity-25" } },
                    { keymaps = { "t" }, classes = { "opacity-30" } },
                    { keymaps = { "a" }, classes = { "opacity-40" } },
                    { keymaps = { "s" }, classes = { "opacity-50" } },
                    { keymaps = { "d" }, classes = { "opacity-60" } },
                    { keymaps = { "f" }, classes = { "opacity-70" } },
                    { keymaps = { "g" }, classes = { "opacity-75" } },
                    { keymaps = { "u" }, classes = { "opacity-80" } },
                    { keymaps = { "i" }, classes = { "opacity-90" } },
                    { keymaps = { "o" }, classes = { "opacity-100" } },
                }, "after")
            end,
            { nowait = true },
        },

        ------------------------------------------ Repeat

        {
            ".",
            function()
                if GAMBIT_PREVIOUS_ACTION then
                    if GAMBIT_PREVIOUS_ACTION == "changing-pms-classes" then
                        pms_menu.apply_previous_action()
                    elseif GAMBIT_PREVIOUS_ACTION == "changing-color-classes" then
                        colors_menu.apply_previous_action()
                    elseif GAMBIT_PREVIOUS_ACTION == "changing-classes-groups" then
                        require("Gambit.ui.replace_classes_menu").apply_previous_action()
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

        -------------------------------------------- Adding Tags

        {
            "I",
            function()
                new_tag("Image")
            end,
            { nowait = true },
        },

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
        {
            "<C-h>",
            function()
                jump_and_highlight_sibling("parent")
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
