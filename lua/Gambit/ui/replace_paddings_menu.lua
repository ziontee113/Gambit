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

local get_class = function(axis, value)
    local class = ""
    if value ~= "" then
        class = "p-" .. value
        class = string.format("p%s-%s", axis, value)
    end
    return class
end

M.show_menu = function(axis)
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
    axis = axis or ""

    local lines = {}
    for _, entry in ipairs(key_value_map) do
        if type(entry) == "string" then
            table.insert(lines, Menu.separator(entry))
        elseif type(entry) == "table" and not entry.hide then
            local key, value = unpack(entry)
            local class = get_class(axis, value)
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
            class_replacer.change_tailwind_paddings(old_winnr, old_bufnr, axis, item.data)
        end,
    })

    --------------------------------------------

    for _, entry in pairs(key_value_map) do
        if type(entry) == "table" then
            local key, value = unpack(entry)
            menu:map("n", key, function()
                menu:unmount()
                local class = get_class(axis, value)
                class_replacer.change_tailwind_paddings(old_winnr, old_bufnr, axis, class)
            end, { nowait = true })
        end
    end

    --------------------------------------------

    menu:mount()
end

return M
