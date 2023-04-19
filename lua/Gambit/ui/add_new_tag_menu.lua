local Menu = require("nui.menu")

local defaults = require("Gambit.options.defaults")

local popup_options = defaults.popup_options
popup_options.border.text.top = "[Add New Tag]"

local M = {}

-- QUESTION: I'm thinking of a center focus design
-- a list item that looks like "  div | h1   "
-- where the user press `h` to add the `div` tag and `l` to add the `h1` tag
-- they can also use a "hotkey", like pressing `p` to specifically add the `p` tag

-- "they can also use a "hotkey", like pressing `p` to specifically add the `p` tag" --> this statement
-- should we just build around from this?
--> we should also think about the "direction / location" of where the new tag will spawn
---> those directions are ["next to", "before", "next to the parent", "before the parent"]

local tag_list = {
    "div",
    "ul",
    "li",
}

M.show_menu = function()
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for _, group in ipairs(classes_groups) do
        local text = table.concat(group, " ")
        table.insert(lines, Menu.item(text, { data = group }))
    end

    local menu = Menu(popup_options, {
        lines = lines,
        max_width = 40,
        keymap = defaults.keymaps,
        on_submit = function(item)
            -- TODO:
        end,
    })

    menu:mount()
end

return M
