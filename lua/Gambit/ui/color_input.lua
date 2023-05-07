local M = {}

M.show = function(winnr, bufnr, propery, menu)
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
                top = "[Color Input]",
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
        on_change = function(value)
            -- TODO: create a module to convert / transform the prompt to actual color values
        end,
    })

    input:mount()
    menu:unmount()

    -------------------------------------------- Mappings

    -- unmount the input while preserving current PSEUDO_CLASSES
    input:map("i", { "<Space>", "<Tab>" }, function()
        input:unmount()
    end, {})

    -- restore default <C-w> behavior in Insert Mode
    input:map("i", "<C-w>", "<C-S-w>", { noremap = true })

    -- clear current PSEUDO_CLASSES
    input:map("i", { "<Esc>" }, function()
        -- TODO:
        input:unmount()
    end, { noremap = true })
end

return M

-- {{{nvim-execute-on-save}}}
