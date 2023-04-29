local M = {}

local colors = {
    { color = false, keys = { "0" }, hide = true },
    { color = "slate", keys = { "sl" } },
    { color = "gray", keys = { "g" } },
    { color = "zinc", keys = { "z" } },
    { color = "neutral", keys = { "n" } },
    { color = "stone", keys = { "st" } },
    { color = "red", keys = { "r" } },
    { color = "orange", keys = { "o" } },
    { color = "amber", keys = { "a" } },
    { color = "yellow", keys = { "y" } },
    { color = "lime", keys = { "l" } },
    { color = "green", keys = { "g" } },
    { color = "emerald", keys = { "e" } },
    { color = "teal", keys = { "t" } },
    { color = "cyan", keys = { "c" } },
    { color = "sky", keys = { "sk" } },
    { color = "blue", keys = { "b" } },
    { color = "indigo", keys = { "i" } },
    { color = "violet", keys = { "v" } },
    { color = "purple", keys = { "p" } },
    { color = "fuchsia", keys = { "f" } },
    { color = "pink", keys = { "P" } },
    { color = "rose", keys = { "R" } },
}

local steps = {
    { step = "100", keys = { "1", "m" } },
    { step = "200", keys = { "2", "," } },
    { step = "300", keys = { "3", "." } },
    { step = "400", keys = { "4", "j" } },
    { step = "500", keys = { "5", "k" } },
    { step = "600", keys = { "6", "l" } },
    { step = "700", keys = { "7", "u" } },
    { step = "800", keys = { "8", "i" } },
    { step = "900", keys = { "9", "o" } },
}

------------------------------------------------------------------------------ Imports

local Menu = require("nui.menu")
local defaults = require("Gambit.options.defaults")
local class_replacer = require("Gambit.lib.class-replacer")

local old_winnr, old_bufnr = 0, 0

------------------------------------------------------------------------------ Steps Menu

local get_full_class = function(colored_prefix, step)
    return string.format("%s-%s", colored_prefix, step)
end

local show_steps_menu = function(property, colored_prefix, winnr, bufnr)
    local lines = {}
    for _, entry in ipairs(steps) do
        if type(entry) == "string" then
            table.insert(lines, Menu.separator(entry))
        elseif type(entry) == "table" and not entry.hide then
            local class = get_full_class(colored_prefix, entry.step)
            table.insert(lines, Menu.item(class))
        end
    end

    local steps_menu = Menu(defaults.popup_options, {
        lines = lines,
        max_width = 40,
        keymap = defaults.keymaps,
        on_submit = function(item)
            class_replacer.change_tailwind_colors(winnr, bufnr, { [property] = item.text })
        end,
    })

    for _, entry in pairs(steps) do
        if type(entry) == "table" then
            for _, key in ipairs(entry.keys) do
                steps_menu:map("n", key, function()
                    steps_menu:unmount()
                    local class = get_full_class(colored_prefix, entry.step)
                    class_replacer.change_tailwind_colors(winnr, bufnr, { [property] = class })
                end, { nowait = true })
            end
        end
    end

    steps_menu:mount()
end

------------------------------------------------------------------------------ Colors Menu

local get_colored_prefix = function(property, color)
    return string.format("%s-%s", property, color)
end

local show_colors_menu = function(property)
    old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local lines = {}
    for _, entry in ipairs(colors) do
        if type(entry) == "string" then
            table.insert(lines, Menu.separator(entry))
        elseif type(entry) == "table" and not entry.hide then
            local display_text = get_colored_prefix(property, entry.color)
            table.insert(lines, Menu.item(display_text))
        end
    end

    local colors_menu = Menu(defaults.popup_options, {
        lines = lines,
        max_width = 40,
        keymap = defaults.keymaps,
        on_submit = function(item)
            show_steps_menu(property, item.text, old_winnr, old_bufnr)
        end,
    })

    for _, entry in pairs(colors) do
        if type(entry) == "table" then
            for _, key in ipairs(entry.keys) do
                colors_menu:map("n", key, function()
                    colors_menu:unmount()
                    if entry.color then
                        show_steps_menu(
                            property,
                            get_colored_prefix(property, entry.color),
                            old_winnr,
                            old_bufnr
                        )
                    else
                        class_replacer.change_tailwind_colors(
                            old_winnr,
                            old_bufnr,
                            { [property] = "" }
                        )
                    end
                end, { nowait = true })
            end
        end
    end

    colors_menu:mount()
end

M.change_text_color = function()
    show_colors_menu("text")
end
M.change_background_color = function()
    show_colors_menu("bg")
end

return M
