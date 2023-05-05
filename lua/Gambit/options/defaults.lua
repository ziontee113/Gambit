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
    focus_next = { "<Down>", "<Tab>" },
    focus_prev = { "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
}


--stylua: ignore
M.valid_hints = {
    "q", "w", "e", "r", "t",
    "a", "s", "d", "f", "g",
    "z", "x", "c", "v", "y",
    "u", "i", "o", "p", "h", "l",
    "n", "m", ",", ".", "/",

    "Q", "W", "E", "R", "T",
    "A", "S", "D", "F", "G",
    "Z", "X", "C", "V", "Y",
    "U", "I", "O", "P", "H", "L",
    "N", "M", "<", ">", "?",
}

return M
