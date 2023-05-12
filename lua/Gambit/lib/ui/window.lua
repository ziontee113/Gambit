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
        vim.keymap.set(
            "n",
            mapping,
            function() vim.api.nvim_win_hide(win) end,
            { buffer = buf, nowait = true }
        )
    end
end

-------------------------------------------- Win Related

local PopUp = {}
PopUp.__index = PopUp

function PopUp:new(opts)
    local popup = setmetatable(opts, PopUp)

    popup.buf = vim.api.nvim_create_buf(false, true)

    local lines = get_lines_from_items(opts.items)
    vim.api.nvim_buf_set_lines(popup.buf, 0, -1, false, lines)

    popup.width = find_longest_line(lines)
    popup.height = #opts.items

    return popup
end

function PopUp:show()
    self.win = vim.api.nvim_open_win(self.buf, true, {
        relative = "cursor",
        row = 1,
        col = 1,
        width = self.width,
        height = self.height,
        style = "minimal",
        border = "single",
        title = self.title or "",
        title_pos = self.title_pos or "center",
    })

    vim.api.nvim_win_set_option(
        self.win,
        "winhl",
        self.winhl or "Normal:Normal,FloatBorder:@function"
    )
    vim.api.nvim_win_set_option(self.win, "cursorline", true)
    set_hide_keymaps(self.win, self.buf, self.keymaps and self.keymaps.hide or { "q", "<Esc>" })
end

--------------------------------------------

local popup = PopUp:new({
    title = "Test",
    items = {
        { keymaps = { "h" }, text = "hello" },
        { keymaps = { "v" }, text = "venus" },
    },
    keymaps = {
        hide = { "z", "q", "<Esc>" },
    },
})

vim.keymap.set("n", "<leader>a", function() popup:show() end, {})

return M

-- {{{nvim-execute-on-save}}}
