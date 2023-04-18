local Menu = require("nui.menu")

local popup_options = {
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

local class_groups = {
    { "flex" },
    { "flex", "flex-row" },
}

local lines = {}
for _, group in ipairs(class_groups) do
    local text = table.concat(group, " ")
    table.insert(lines, Menu.item(text, { data = group }))
end

local menu = Menu(popup_options, {
    lines = lines,
    max_width = 40,
    keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>", "q" },
        submit = { "<CR>", "<Space>", "l" },
    },
    on_close = function()
        print("CLOSED")
    end,
    on_submit = function(item)
        N(item.text)
        N(item.data)
    end,
})

REMAP("n", "<Plug>[L1 A, L1 S], (L1 S) --up<Plug>", function()
    menu:mount()
end)

-- {{{nvim-execute-on-save}}}
