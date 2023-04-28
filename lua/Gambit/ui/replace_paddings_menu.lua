local M = {}

local key_value_map = {
    { "n", "0" },
    { "w", "10" },
    { "e", "11" },
    { "r", "12" },
    { "t", "14" },

    { "y", "16" },
    { "u", "20" },
    { "i", "24" },
    { "o", "28" },
    { "p", "32" },

    { "a", "36" },
    { "s", "40" },
    { "d", "44" },
    { "f", "48" },
    { "g", "52" },

    { "z", "56" },
    { "x", "60" },
    { "c", "64" },
    { "v", "72" },
    { "b", "80" },

    { "m", "96" },
}

local Menu = require("nui.menu")

local defaults = require("Gambit.options.defaults")
local class_replacer = require("Gambit.lib.class-replacer")

M.show_menu = function()
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for i, _ in ipairs(key_value_map) do
        local key, value = unpack(key_value_map[i])
        local class = "p-" .. value
        local display_text = string.format("%s %s", key, class)
        table.insert(lines, Menu.item(display_text, { data = class }))
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
            class_replacer.change_tailwind_paddings(old_winnr, old_bufnr, item.data)
        end,
    })

    --------------------------------------------

    for i, _ in pairs(key_value_map) do
        local key, value = unpack(key_value_map[i])
        menu:map("n", key, function()
            menu:unmount()
            local class = "p-" .. value
            class_replacer.change_tailwind_paddings(old_winnr, old_bufnr, class)
        end, { nowait = true })
    end

    --------------------------------------------

    local quick_number_map = {
        ["0"] = "",
        ["1"] = "1",
        ["2"] = "2",
        ["3"] = "3",
        ["4"] = "4",
        ["5"] = "5",
        ["6"] = "6",
        ["7"] = "7",
        ["8"] = "8",
        ["9"] = "9",

        [")"] = "0.5",
        ["!"] = "1.5",
        ["@"] = "2.5",
        ["#"] = "3.5",
    }

    for key, value in pairs(quick_number_map) do
        menu:map("n", key, function()
            menu:unmount()
            local text = ""
            if value ~= "" then
                text = "p-" .. value
            end
            class_replacer.change_tailwind_paddings(old_winnr, old_bufnr, text)
        end)
    end

    menu:mount()
end

return M
