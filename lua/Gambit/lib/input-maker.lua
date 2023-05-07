local M = {}

M.create_input = function(border_top_text, callback)
    local Input = require("nui.input")

    local popup_options = {
        relative = "cursor",
        enter = true,
        position = {
            row = 1,
            col = 0,
        },
        size = 20,
        border = {
            style = "rounded",
            text = {
                top = border_top_text,
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:@function",
        },
    }

    local input = Input(popup_options, {
        prompt = "> ",
        default_value = "",
        on_submit = function(input)
            callback(input)
        end,
    })

    input:mount()

    -------------------------------------------- Mappings

    -- keys to unmount the input
    input:map("i", { "<Space>", "<Tab>", "<Esc>" }, function()
        input:unmount()
    end, {})

    -- restore default <C-w> behavior in Insert Mode
    input:map("i", "<C-w>", "<C-S-w>", { noremap = true })
end

return M
