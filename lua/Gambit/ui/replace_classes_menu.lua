local Menu = require("nui.menu")

local defaults = require("Gambit.options.defaults")
local class_replacer = require("Gambit.lib.class-replacer")

local M = {}

M.show_menu = function(classes_groups)
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for _, group in ipairs(classes_groups) do
        if not group.hidden then
            local text = group.keymap .. " " .. table.concat(group.classes, " ")
            table.insert(lines, Menu.item(text, { data = group }))
        end
    end

    local menu = Menu(defaults.popup_options, {
        lines = lines,
        max_width = 40,
        keymap = defaults.keymaps,
        on_submit = function(item)
            class_replacer.apply_classes_group(old_winnr, old_bufnr, classes_groups, item.data)
        end,
    })

    for _, group in ipairs(classes_groups) do
        menu:map("n", group.keymap, function()
            menu:unmount()
            class_replacer.apply_classes_group(old_winnr, old_bufnr, classes_groups, group)
        end, { nowait = true })
    end

    menu:mount()
end

return M
