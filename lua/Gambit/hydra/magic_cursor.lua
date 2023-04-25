local Hydra = require("hydra")

local lib_ts = require("Gambit.lib.tree-sitter")
local lib_highlighting = require("Gambit.lib.highlighting")
local lib_tag_creation = require("Gambit.lib.tag-creation")

local lib_cosmic_cursor = require("Gambit.lib.cosmic-cursor")

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

        if opts.auto_enter then
            insert_new_tags_inside = true
        end

        vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
        lib_highlighting.highlight_tag_braces(namespace, 0, insert_new_tags_inside)
    end)
end

local jump = function(direction)
    local count = require("Gambit.lib.vim-utils").get_count()

    for _ = 1, count do
        lib_cosmic_cursor.jump(direction, 0)
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
            if not lib_highlighting.highlight_tag_braces(ns) then
                local root = lib_ts.get_root("tsx")
                local queried_nodes = lib_ts.get_all_nodes_matches_query(
                    [[
((jsx_opening_element) @element)
((jsx_closing_element) @element)
((jsx_self_closing_element) @element)
                ]],
                    "tsx",
                    root
                )

                local line_numbers = {}
                for _, node in ipairs(queried_nodes) do
                    local start_row, _, _, _ = node:range()
                    table.insert(line_numbers, start_row)
                end

                local current_line_number = unpack(vim.api.nvim_win_get_cursor(0))
                local closest_line_number = line_numbers[1]
                for _, line_number in ipairs(line_numbers) do
                    if
                        math.abs(line_number - current_line_number)
                        < math.abs(closest_line_number - current_line_number)
                    then
                        closest_line_number = line_number
                    end
                end

                vim.api.nvim_win_set_cursor(0, { closest_line_number + 1, 0 })
                vim.cmd("norm! ^")
                lib_highlighting.highlight_tag_braces(ns)
            end
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
                new_tag({ tag = "div", auto_enter = true }, ns)
            end,
            { nowait = true },
        },
        {
            "U",
            function()
                new_tag({ tag = "ul", auto_enter = true }, ns)
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
