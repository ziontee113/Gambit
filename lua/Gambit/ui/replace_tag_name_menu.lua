local Menu = require("nui.menu")

local defaults = require("Gambit.options.defaults")
local tag_name_replacer = require("Gambit.lib.tag-name-replacer")

local M = {}

local change_arguments
M.show = function(tag_groups)
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for _, group in ipairs(tag_groups) do
        local text = string.format("%s %s", group.keymaps[1], group.tag)
        table.insert(lines, Menu.item(text, { data = group }))
    end

    local menu = Menu(defaults.popup_options, {
        lines = lines,
        max_width = 40,
        keymap = defaults.keymaps,
        on_submit = function(item)
            change_arguments = {
                winnr = old_winnr,
                bufnr = old_bufnr,
                tag = item.data.tag,
            }
            tag_name_replacer.replace_to(change_arguments)
        end,
    })

    for _, group in ipairs(tag_groups) do
        for _, keymap in ipairs(group.keymaps) do
            menu:map("n", keymap, function()
                menu:unmount()
                change_arguments = {
                    winnr = old_winnr,
                    bufnr = old_bufnr,
                    tag = group.tag,
                }
                tag_name_replacer.replace_to(change_arguments)
            end, { nowait = true })
        end
    end

    menu:mount()
end

M.apply_previous_action = function(node)
    if change_arguments ~= nil then
        change_arguments.node = node
        tag_name_replacer.replace_to(change_arguments)
    end
end

return M
