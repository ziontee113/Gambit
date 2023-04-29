local M = {}

M.popup_options = {
    relative = "cursor",
    position = {
        row = 1,
        col = 0,
    },
    border = {
        style = "rounded",
        text = {
            top = "[Choose Item]",
            top_align = "center",
        },
    },
    win_options = {
        winhighlight = "Normal:Normal",
    },
}

M.keymaps = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>", "l" },
}

return M
