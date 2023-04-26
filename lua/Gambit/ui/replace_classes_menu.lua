local Menu = require("nui.menu")

local lib_ts = require("Gambit.lib.tree-sitter")
local manipulator = require("Gambit.lib.class-manipulator")
local defaults = require("Gambit.options.defaults")

local M = {}

local classes_groups = {
    { "flex" },
    { "flex", "flex-row" },
}

M.show_menu = function()
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for _, group in ipairs(classes_groups) do
        local text = table.concat(group, " ")
        table.insert(lines, Menu.item(text, { data = group }))
    end

    local menu = Menu(defaults.popup_options, {
        lines = lines,
        max_width = 40,
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>", "q" },
            submit = { "<CR>", "<Space>", "l" },
        },
        on_submit = function(item)
            local tag_node, className_prop_identifier_node, className_string_node =
                lib_ts.get_className_related_nodes(old_winnr)

            local old_classes = ""
            if className_string_node then
                old_classes = vim.treesitter.get_node_text(className_string_node, old_bufnr)
                old_classes = string.gsub(old_classes, "[\"']", "")
            end

            local new_classes =
                manipulator.replace_classes_with_list_item(old_classes, classes_groups, item.data)
            new_classes = string.format('"%s"', new_classes)

            if tag_node then
                if className_prop_identifier_node then
                    lib_ts.replace_node_text(old_bufnr, className_string_node, new_classes)
                else
                    local _, _, end_row, end_col = tag_node:range()
                    vim.api.nvim_buf_set_text(
                        old_bufnr,
                        end_row,
                        end_col,
                        end_row,
                        end_col,
                        { string.format(" className=%s", new_classes) }
                    )
                end
            end
        end,
    })

    menu:mount()
end

return M
