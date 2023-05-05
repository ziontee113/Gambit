local M = {}

local find_image_paths = function(callback)
    local cmd = { "fd" }
    local extensions = { "jpg", "png", "svg" }

    for _, extension in ipairs(extensions) do
        table.insert(cmd, "-e")
        table.insert(cmd, extension)
    end

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local paths = {}
            for _, path in ipairs(data) do
                if path ~= "" then
                    table.insert(paths, path)
                end
            end
            callback(paths)
        end,
    })
end

local trim_pattern_from_strings = function(paths, pattern)
    local results = {}
    for _, path in ipairs(paths) do
        local trimmed_path = string.gsub(path, pattern, "")
        table.insert(results, trimmed_path)
    end
    return results
end

------------------------------------------------------------------------------ Imports

local Menu = require("nui.menu")
local defaults = require("Gambit.options.defaults")
local prop_replacer = require("Gambit.lib.prop-replacer")

local menu_keymaps = {
    focus_next = { "<Down>", "<Tab>" },
    focus_prev = { "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
}

local old_winnr, old_bufnr = 0, 0
local change_arguments

------------------------------------------------------------------------------ Paths Menu

local show_paths_menu = function(paths)
    old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
    local lines = {}

    paths = trim_pattern_from_strings(paths, "^public")

    for i, path in ipairs(paths) do
        local display_text = defaults.valid_hints[i] .. " " .. path
        table.insert(lines, Menu.item(display_text, { path = path }))
    end

    local groups_menu = Menu(defaults.popup_options, {
        lines = lines,
        keymap = menu_keymaps,
        on_submit = function(item)
            change_arguments = { old_winnr, old_bufnr, "src", item.path }
            prop_replacer.replace_prop(unpack(change_arguments))
        end,
    })

    for i, path in ipairs(paths) do
        local key = defaults.valid_hints[i]
        if key then
            groups_menu:map("n", key, function()
                groups_menu:unmount()
                change_arguments = { old_winnr, old_bufnr, "src", path }
                prop_replacer.replace_prop(unpack(change_arguments))
            end, { nowait = true })
        end
    end

    groups_menu:mount()
end

M.replace_img_src = function()
    find_image_paths(show_paths_menu)
end

return M
