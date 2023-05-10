local M = {}

local key_value_map = {
    { "0", "", hide = true },
    { "1", "1", hide = true },
    { "2", "2", hide = true },
    { "3", "3", hide = true },
    { "4", "4", hide = true },
    { "5", "5", hide = true },
    { "6", "6", hide = true },
    { "7", "7", hide = true },
    { "8", "8", hide = true },
    { "9", "9", hide = true },
    -- "",
    { "w", "10" },
    { "e", "11" },
    { "r", "12" },
    { "t", "14" },
    "",
    { "y", "16" },
    { "u", "20" },
    { "i", "24" },
    { "o", "28" },
    { "p", "32" },
    "",
    { "a", "36" },
    { "s", "40" },
    { "d", "44" },
    { "f", "48" },
    { "g", "52" },
    "",
    { "z", "56" },
    { "x", "60" },
    { "c", "64" },
    { "v", "72" },
    { "b", "80" },
    { "n", "96" },
    { "m", "0" },

    { ")", "0.5", hide = true },
    { "!", "1.5", hide = true },
    { "@", "2.5", hide = true },
    { "#", "3.5", hide = true },
}

local Menu = require("nui.menu")

local defaults = require("Gambit.options.defaults")
local class_replacer = require("Gambit.lib.class-replacer")

local get_class = function(property, axis, value)
    local class = ""
    if value ~= "" then
        class = string.format("%s%s-%s", property, axis, value)
    end
    return class
end

local change_arguments
M.change_arguments = function(args)
    change_arguments = args
end
local old_winnr, old_bufnr = 0, 0
local show_menu = function(property, axis, axies_to_remove)
    old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
    axis = axis or ""
    axies_to_remove = axies_to_remove or {}

    local lines = {}
    for _, entry in ipairs(key_value_map) do
        if type(entry) == "string" then
            table.insert(lines, Menu.separator(entry))
        elseif type(entry) == "table" and not entry.hide then
            local key, value = unpack(entry)
            local class = get_class(property, axis, value)
            local display_text = string.format("%s %s", key, class)
            table.insert(lines, Menu.item(display_text, { data = class }))
        end
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
            change_arguments = {
                winnr = old_winnr,
                bufnr = old_bufnr,
                property = property,
                axis = axis,
                axies_to_remove = axies_to_remove,
                replacement = item.data,
            }
            class_replacer.change_pms_classes(change_arguments)
        end,
    })

    --------------------------------------------

    for _, entry in pairs(key_value_map) do
        if type(entry) == "table" then
            local key, value = unpack(entry)
            menu:map("n", key, function()
                menu:unmount()
                local class = get_class(property, axis, value)
                change_arguments = {
                    winnr = old_winnr,
                    bufnr = old_bufnr,
                    property = property,
                    axis = axis,
                    axies_to_remove = axies_to_remove,
                    replacement = class,
                }
                class_replacer.change_pms_classes(change_arguments)
            end, { nowait = true })
        end
    end

    --------------------------------------------

    menu:mount()
end

M.show_paddings_menu = function(axis, axies_to_remove_beforehand)
    show_menu("p", axis, axies_to_remove_beforehand)
end
M.show_margins_menu = function(axis, axies_to_remove_beforehand)
    show_menu("m", axis, axies_to_remove_beforehand)
end
M.show_spacing_menu = function(axis, axies_to_remove_beforehand)
    show_menu("space-", axis, axies_to_remove_beforehand)
end

M.apply_previous_action = function(node)
    if change_arguments ~= nil then
        change_arguments.node = node
        class_replacer.change_pms_classes(change_arguments)
    end
end

return M
