local M = {}

local get_content_groups_from_file = function(file_path)
    local file_lines = vim.fn.readfile(file_path)
    local groups = {}

    for _, line in ipairs(file_lines) do
        if line ~= "" then
            if string.match(line, "^%s+") then
                if #groups > 0 then
                    local trimmed_line = string.gsub(line, "^%s+", "")
                    table.insert(groups[#groups], trimmed_line)
                end
            else
                table.insert(groups, { name = line })
            end
        elseif #groups > 0 then
            table.insert(groups[#groups], "")
        end
    end

    return groups
end

------------------------------------------------------------------------------ Imports

local Menu = require("nui.menu")
local defaults = require("Gambit.options.defaults")
local content_replacer = require("Gambit.lib.content-replacer")

local menu_keymaps = {
    focus_next = { "<Down>", "<Tab>" },
    focus_prev = { "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
}

local old_winnr, old_bufnr = 0, 0
local change_arguments

-------------------------------------------- Valid Hint Finder

local find_valid_hint = function(content, hint_pool, occupied_hints)
    local first_char = string.sub(content, 1, 1)
    local lowercase_candidate = string.lower(first_char)
    local uppercase_candidate = string.upper(first_char)

    if
        not vim.tbl_contains(occupied_hints, lowercase_candidate)
        and vim.tbl_contains(hint_pool, lowercase_candidate)
    then
        return lowercase_candidate
    elseif
        not vim.tbl_contains(occupied_hints, uppercase_candidate)
        and vim.tbl_contains(hint_pool, uppercase_candidate)
    then
        return uppercase_candidate
    else
        for _, hint in ipairs(hint_pool) do
            if not vim.tbl_contains(occupied_hints, hint) then
                return hint
            end
        end
    end
end

-------------------------------------------- Content Menu

local show_content_menu = function(winnr, bufnr, content_group)
    local lines = {}
    local occupied_hints = {}
    for i, line in ipairs(content_group) do
        if line == "" then
            if i < #content_group then
                table.insert(lines, Menu.separator(""))
            end
        else
            local hint = find_valid_hint(line, defaults.valid_hints, occupied_hints)
            local display_text = hint .. " " .. line
            table.insert(lines, Menu.item(display_text, { data = line }))
            table.insert(occupied_hints, hint)
        end
    end

    local content_menu = Menu(defaults.popup_options, {
        lines = lines,
        keymap = menu_keymaps,
        on_submit = function(item)
            change_arguments = { winnr, bufnr, item.data }
            content_replacer.replace_jsx_text(unpack(change_arguments))
        end,
    })

    local hint_count = 1
    for _, line in ipairs(content_group) do
        if line ~= "" then
            local key = occupied_hints[hint_count]
            hint_count = hint_count + 1
            if key then
                content_menu:map("n", key, function()
                    content_menu:unmount()
                    change_arguments = { winnr, bufnr, line }
                    content_replacer.replace_jsx_text(unpack(change_arguments))
                end, { nowait = true })
            end
        end
    end

    content_menu:mount()
end

-------------------------------------------- Groups Menu

local show_groups_menu = function(file_path)
    old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
    local groups = get_content_groups_from_file(file_path)

    local lines = {}
    local occupied_hints = {}

    for _, group in ipairs(groups) do
        local hint = find_valid_hint(group.name, defaults.valid_hints, occupied_hints)
        local display_text = hint .. " " .. group.name
        table.insert(lines, Menu.item(display_text, { data = group }))
        table.insert(occupied_hints, hint)
    end

    local groups_menu = Menu(defaults.popup_options, {
        lines = lines,
        keymap = menu_keymaps,
        on_submit = function(item)
            show_content_menu(old_winnr, old_bufnr, item.data)
        end,
    })

    for i, group in ipairs(groups) do
        local key = occupied_hints[i]
        if key then
            groups_menu:map("n", key, function()
                groups_menu:unmount()
                show_content_menu(old_winnr, old_bufnr, group)
            end, { nowait = true })
        end
    end

    groups_menu:mount()
end

M.replace_content = function(file_path)
    show_groups_menu(file_path)
end

return M
