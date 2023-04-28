local M = {}

--stylua: ignore
local number_values = {
    "", 0.5, 0, 1, 1.5, 2, 2.5, 3, 3.5,
    4, 5, 6, 7, 8, 9, 10,
    11, 12, 14, 16,
    20, 24, 28, 32, 36, 40, 44, 48,
    52, 56, 60, 64, 72, 80, 96,
}

local Menu = require("nui.menu")

local defaults = require("Gambit.options.defaults")
local class_replacer = require("Gambit.lib.class-replacer")

M.show_menu = function()
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for _, value in ipairs(number_values) do
        local text = value
        if value ~= "" then
            text = "p-" .. value
        end
        table.insert(lines, Menu.item(text, { data = text }))
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

    menu:mount()
end

return M
