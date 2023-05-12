local M = {}

-------------------------------------------- Utility

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

-------------------------------------------- PopUp

local PopUp = {
    keymaps = {},
    items = {},
}
PopUp.__index = PopUp

-- Private

function PopUp:_execute_callback(item_index)
    self.callback(self.items[item_index].text)
    self:hide()
end

function PopUp:_set_hide_keymaps()
    if not self.keymaps.hide then
        self.keymaps.hide = { "<Esc>", "q" }
    end

    for _, mapping in ipairs(self.keymaps.hide) do
        vim.keymap.set(
            "n",
            mapping,
            function() vim.api.nvim_win_hide(self.win) end,
            { buffer = self.buf, nowait = true }
        )
    end
end

function PopUp:_set_confirm_keymaps()
    if not self.keymaps.confirm then
        self.keymaps.confirm = { "<CR>" }
    end

    for _, mapping in ipairs(self.keymaps.confirm) do
        vim.keymap.set("n", mapping, function()
            local cursor_line = unpack(vim.api.nvim_win_get_cursor(0))
            self:_execute_callback(cursor_line)
        end, { buffer = self.buf, nowait = true })
    end
end

function PopUp:_set_user_keymaps()
    for item_index, item in ipairs(self.items) do
        if item.keymaps then
            for _, keymap in ipairs(item.keymaps) do
                vim.keymap.set(
                    "n",
                    keymap,
                    function() self:_execute_callback(item_index) end,
                    { buffer = self.buf, nowait = true }
                )
            end
        end
    end
end

-- Public

function PopUp:new(opts)
    local popup = setmetatable(opts, PopUp)

    popup.buf = vim.api.nvim_create_buf(false, true)

    local lines = get_lines_from_items(opts.items)
    vim.api.nvim_buf_set_lines(popup.buf, 0, -1, false, lines)

    popup.width = find_longest_line(lines)
    popup.height = #opts.items

    popup:_set_user_keymaps()
    popup:_set_confirm_keymaps()

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

    self:_set_hide_keymaps()
end

function PopUp:hide() vim.api.nvim_win_hide(self.win) end

-------------------------------------------- Testing

local popup = PopUp:new({
    title = "Test",
    items = {
        { keymaps = { "h" }, text = "hello" },
        { keymaps = { "v" }, text = "venus" },
    },
    keymaps = {
        hide = { "z", "q", "<Esc>" },
    },
    callback = function(result) N(result) end,
})

vim.keymap.set("n", "<leader>a", function() popup:show() end, {})

return M

-- {{{nvim-execute-on-save}}}
