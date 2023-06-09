local Hydra = require("hydra")

local lua_patterns = require("Gambit.lua_patterns")

local navigation = require("Gambit.api.navigation")
local tag_api = require("Gambit.api.tag")
local mandatory_events = require("Gambit.api.mandatory_events")

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

_a_: align _fl_: flex _C_: custom presets

_t_ _T_: text-color _b_ _B_: background-color
_z_: font-size  _fw_: font-weight
_fs_:font-style _D_: text-decoration _<C-a>_: text-align
_O_: opacity

_._: repeat _u_: undo _q_, _<Esc>_: exit 
]]

--------------------------------------------

REMAP({ "n", "x", "i" }, "<Plug>R1 B --down<Plug>", "<Nop>")

local pms_menu = require("Gambit.ui.pms_menu")
local colors_menu = require("Gambit.ui.colors_menu")

PSEUDO_CLASSES = ""

local pseudo_classes_input = require("Gambit.ui.pseudo_classes_input")
local visual_mode = require("Gambit.lib.visual-mode")

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
        on_enter = function() mandatory_events.enter() end,
        on_exit = function() mandatory_events.exit() end,
    },
    mode = "n",
    body = "<Plug>R1 B --down<Plug>",
    heads = {
        -- Changing Pseudo Classes
        { "<Tab>", function() pseudo_classes_input.show() end, { nowait = true } },

        -- Toggle Custom Visual Mode
        { "v", function() visual_mode.toggle() end, { nowait = true } },

        -- Delete current / selected tags
        { "d", function() require("Gambit.api.delete").delete_tags() end, { nowait = true } },

        -- Wrap current / selected tags in another tag
        {
            "w",
            function()
                require("Gambit.api.wrap").wrap_selected_nodes_in_tag({
                    tag = "div",
                    indent_by = 2,
                })
            end,
            { nowait = true },
        },

        -- Replace current / selected tags' tag names
        {
            "R",
            function()
                require("Gambit.ui.replace_tag_name_menu").show({
                    { keymaps = { "d", "D" }, tag = "div" },
                    { keymaps = { "u", "U" }, tag = "ul" },
                    { keymaps = { "s", "S" }, tag = "section" },
                })
            end,
            { nowait = true },
        },

        -- Toggle new tag destination
        { "o", function() navigation.toggle_new_tag_destination() end, { nowait = true } },

        -- Change tag content if user have text object plugin installed
        {
            "i",
            function()
                vim.cmd("norm! cit")
                vim.cmd("startinsert")
                vim.api.nvim_input("<Right>")
            end,
            { nowait = true },
        },

        -------------------------------------------- Replacing Content

        -- Replace current tag's content with empty expression, then enter insert mode.
        {
            "<C-S-;>",
            function()
                require("Gambit.lib.content-replacer").replace_jsx_text_with_empty_expression(0, 0)
            end,
            { nowait = true },
        },

        -- Replace given attribute's content with empty expression, then enter insert mode.
        {
            "<C-S-A>",
            function()
                require("Gambit.lib.attribute-replacer").replace_attribute_with_empty_jsx_expression({
                    winnr = 0,
                    bufnr = 0,
                    attribute = "alt",
                })
            end,
            { nowait = true },
        },

        -- Replace current tag's content with contents in `contents.txt` file
        {
            "h",
            function() require("Gambit.ui.text_content_menu").replace_content("contents.txt") end,
            { nowait = true },
        },

        -- Replace current tag's `src` attribute, requires `fd`.
        {
            "sr",
            function() require("Gambit.ui.image_src_menu").replace_img_src() end,
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
            "D",
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
            "C",
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
                        tag_api.repeat_previous_action()
                    end
                end
            end,
            { nowait = true },
        },

        {
            "<C-.>",
            function() require("Gambit.lib.class-repeater").repeat_classes_to_all_siblings(0, 0) end,
            { nowait = true },
        },

        {
            "<C-S-.>",
            function()
                require("Gambit.lib.class-replacer").replicate_all_classes_to_all_siblings(0, 0)
            end,
            { nowait = true },
        },

        ------------------------------------------ colors

        {
            "t",
            function() colors_menu.change_text_color() end,
            { nowait = true },
        },
        {
            "T",
            function() require("Gambit.ui.color_input").show(0, 0, "text") end,
            { nowait = true },
        },

        {
            "b",
            function() colors_menu.change_background_color() end,
            { nowait = true },
        },
        {
            "B",
            function() require("Gambit.ui.color_input").show(0, 0, "bg") end,
            { nowait = true },
        },

        -------------------------------------------- change pseudo_element content

        {
            ",c",
            function() require("Gambit.ui.content_input").show(0, 0) end,
            { nowait = true },
        },

        ------------------------------------------ paddings
        {
            "P",
            function() pms_menu.show_paddings_menu("") end,
            { nowait = true },
        },
        {
            "<C-S-P>",
            function() pms_menu.show_paddings_menu("", "all") end,
            { nowait = true },
        },
        {
            ",P",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "", "") end,
            { nowait = true },
        },

        ----- padding x and y
        {
            "py",
            function() pms_menu.show_paddings_menu("y") end,
            { nowait = true },
        },
        {
            ",py",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "y", "") end,
            { nowait = true },
        },

        {
            "pY",
            function() pms_menu.show_paddings_menu("x", { "t", "b" }) end,
            { nowait = true },
        },
        {
            ",pY",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "y", { "t", "b" }) end,
            { nowait = true },
        },

        {
            "px",
            function() pms_menu.show_paddings_menu("x") end,
            { nowait = true },
        },
        {
            ",px",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "x", "") end,
            { nowait = true },
        },
        {
            "pX",
            function() pms_menu.show_paddings_menu("x", { "l", "r" }) end,
            { nowait = true },
        },
        {
            ",pX",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "x", { "l", "r" }) end,
            { nowait = true },
        },

        {
            "p<C-y>",
            function() pms_menu.show_paddings_menu("y", "all") end,
            { nowait = true },
        },
        {
            ",p<C-y>",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "y", "all") end,
            { nowait = true },
        },
        {
            "p<C-x>",
            function() pms_menu.show_paddings_menu("x", "all") end,
            { nowait = true },
        },
        {
            ",p<C-x>",
            function() require("Gambit.ui.pms_input").show(0, 0, "p", "x", "all") end,
            { nowait = true },
        },

        ----- padding t,b,l,r
        {
            "pl",
            function() pms_menu.show_paddings_menu("l") end,
            { nowait = true },
        },
        {
            "pr",
            function() pms_menu.show_paddings_menu("r") end,
            { nowait = true },
        },
        {
            "pt",
            function() pms_menu.show_paddings_menu("t") end,
            { nowait = true },
        },
        {
            "pb",
            function() pms_menu.show_paddings_menu("b") end,
            { nowait = true },
        },

        ------------------------------------------ margins
        {
            "M",
            function() pms_menu.show_margins_menu("") end,
            { nowait = true },
        },
        {
            "<C-S-M>",
            function() pms_menu.show_margins_menu("", "all") end,
            { nowait = true },
        },

        ----- padding x and y
        {
            "my",
            function() pms_menu.show_margins_menu("y") end,
            { nowait = true },
        },
        {
            "mx",
            function() pms_menu.show_margins_menu("x") end,
            { nowait = true },
        },

        ----- padding t,b,l,r
        {
            "ml",
            function() pms_menu.show_margins_menu("l") end,
            { nowait = true },
        },
        {
            "mr",
            function() pms_menu.show_margins_menu("r") end,
            { nowait = true },
        },
        {
            "mt",
            function() pms_menu.show_margins_menu("t") end,
            { nowait = true },
        },
        {
            "mb",
            function() pms_menu.show_margins_menu("b") end,
            { nowait = true },
        },

        ------------------------------------------ spacing
        {
            "sx",
            function() pms_menu.show_spacing_menu("x") end,
            { nowait = true },
        },
        {
            "sy",
            function() pms_menu.show_spacing_menu("y") end,
            { nowait = true },
        },

        {
            "sX",
            function() pms_menu.show_spacing_menu("x", "all") end,
            { nowait = true },
        },
        {
            "sY",
            function() pms_menu.show_spacing_menu("y", "all") end,
            { nowait = true },
        },

        -------------------------------------------- Adding Tags

        {
            "I",
            function() tag_api.new({ tag = "Image" }) end,
            { nowait = true },
        },

        {
            "D",
            function() tag_api.new({ tag = "div", enter = true }) end,
            { nowait = true },
        },
        {
            "U",
            function() tag_api.new({ tag = "ul", enter = true }) end,
            { nowait = true },
        },
        {
            "l",
            function() tag_api.new({ tag = "li" }) end,
            { nowait = true },
        },

        -------------------------------------------- Jumping to Previous / Next Tag

        {
            "j",
            function() navigation.jump_and_highlight({ direction = "next" }) end,
            { nowait = true },
        },
        {
            "k",
            function() navigation.jump_and_highlight({ direction = "previous" }) end,
            { nowait = true },
        },

        {
            "J",
            function()
                navigation.jump_and_highlight({ direction = "next", skip_visual_mode = true })
            end,
            { nowait = true },
        },
        {
            "K",
            function()
                navigation.jump_and_highlight({ direction = "previous", skip_visual_mode = true })
            end,
            { nowait = true },
        },

        -------------------------------------------- Jumping to Previous / Next JSX Sibling

        {
            "<C-j>",
            function() navigation.jump_and_highlight_sibling("next") end,
            { nowait = true },
        },
        {
            "<C-k>",
            function() navigation.jump_and_highlight_sibling("previous") end,
            { nowait = true },
        },
        {
            "<C-h>",
            function() navigation.jump_and_highlight_sibling("parent") end,
            { nowait = true },
        },

        -------------------------------------------- Undo with updated highlighting

        {
            "u",
            function()
                vim.cmd("norm! u")
                navigation.jump_and_highlight({ direction = "in-place" })
            end,
            { nowait = true },
        },

        --------------------------------------------

        { "<Esc>", nil, { exit = true, nowait = true } },
        { "q", nil, { exit = true, nowait = true } },
    },
})

-- {{{nvim-execute-on-save}}}
