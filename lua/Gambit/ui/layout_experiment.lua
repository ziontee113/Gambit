local Layout = require("nui.layout")
local Popup = require("nui.popup")

local left_popup = Popup({ border = "single", enter = true })
local right_popup = Popup({ border = "single" })

local layout = Layout(
    {
        position = "50%",
        size = {
            width = 80,
            height = 40,
        },
    },
    Layout.Box({
        Layout.Box(left_popup, { size = "40%" }),
        Layout.Box(right_popup, { size = "60%" }),
    }, { dir = "row" })
)

vim.keymap.set("n", "<leader>a", function()
    layout:mount()
end, {})

-- {{{nvim-execute-on-save}}}
