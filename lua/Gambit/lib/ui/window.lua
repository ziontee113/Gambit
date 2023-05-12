local M = {}

--------------------------------------------

local find_longest_line = function(lines)
    local longest = 1
    for _, line in ipairs(lines) do
        if #line > longest then
            longest = #line
        end
    end
    return longest
end

local get_lines_from_items = function(items)
    local lines = {}
    for _, item in ipairs(items) do
        local keymap_prefix = ""
        if item.keymaps and item.keymaps[1] then
            keymap_prefix = item.keymaps[1] .. " "
        end
        table.insert(lines, keymap_prefix .. item.text)
    end
    return lines
end

-------------------------------------------- Buf Related

local set_hide_keymaps = function(win, buf, keymaps)
    for _, mapping in ipairs(keymaps) do
        vim.keymap.set("n", mapping, function() vim.api.nvim_win_hide(win) end, { buffer = buf })
    end
end

-------------------------------------------- Win Related

local open_win = function(buf, opts)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 1,
        width = opts.width,
        height = opts.height,
        style = "minimal",
        border = "single",
        title = opts.title or "",
        title_pos = opts.title_pos or "center",
    })

    vim.api.nvim_win_set_option(win, "winhl", opts.winhl or "Normal:Normal,FloatBorder:@function")
    vim.api.nvim_win_set_option(win, "cursorline", true)

    return win
end

--------------------------------------------

M.new = function(opts)
    local buf = vim.api.nvim_create_buf(false, true)

    local lines = get_lines_from_items(opts.items)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    opts.width = find_longest_line(lines)
    opts.height = #opts.items

    local win = open_win(buf, opts)

    set_hide_keymaps(win, buf, opts.keymap and opts.keymap.hide or { "q", "<Esc>" })

    return win, buf
end

--------------------------------------------

vim.keymap.set(
    "n",
    "<leader>a",
    function()
        M.new({
            title = "Test",
            items = {
                { keymaps = { "h" }, text = "hello" },
                { keymaps = { "v" }, text = "venus" },
            },
        })
    end,
    {}
)

return M

-- {{{nvim-execute-on-save}}}
