local Popup = require("nui.popup")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")

local lib_tag_creation = require("Gambit.lib.tag-creation")

local M = {}

local create_popup = function()
    local old_winnr, old_bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

    local popup = Popup({
        position = {
            row = "50%",
            col = "100%",
        },
        size = {
            width = 20,
            height = 1,
        },
        enter = true,
        focusable = true,
        zindex = 50,
        relative = "editor",
        border = {
            padding = {
                top = 0,
                bottom = 0,
                left = 0,
                right = 0,
            },
            style = "rounded",
            text = {
                top = " I am top title ",
                top_align = "center",
                bottom = " I am bottom title ",
                bottom_align = "left",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:@event",
        },
    })

    popup:map("n", { "q", "<Esc>" }, function()
        popup:unmount()
    end, {})

    popup:map("n", "d", function()
        lib_tag_creation.create_tag_at_cursor("div", old_winnr, old_bufnr, true, false)
    end, { nowait = true })

    popup:map("n", "l", function()
        lib_tag_creation.create_tag_at_cursor("li", old_winnr, old_bufnr, true, false)
    end, { nowait = true })
    popup:map("n", "!", function()
        lib_tag_creation.create_tag_at_cursor("h1", old_winnr, old_bufnr, true, false)
    end, { nowait = true })
    popup:map("n", "@", function()
        lib_tag_creation.create_tag_at_cursor("h2", old_winnr, old_bufnr, true, false)
    end, { nowait = true })
    popup:map("n", "#", function()
        lib_tag_creation.create_tag_at_cursor("h3", old_winnr, old_bufnr, true, false)
    end, { nowait = true })

    popup:map("n", "u", function()
        vim.api.nvim_buf_call(old_bufnr, function()
            vim.cmd("norm! u")
        end)
    end, {})
    popup:map("n", "<C-r>", function()
        vim.api.nvim_buf_call(old_bufnr, function()
            vim.cmd("norm! ")
        end)
    end, {})

    popup:map("n", "<Tab>", function()
        popup.border:set_text("top", " I'm the boss ", "center")
        popup.border:set_text("bottom", "", "center")
        popup.border:set_highlight("@function")
    end, {})

    return popup
end

M.show_menu = function()
    local popup = create_popup()
    popup:mount()
end

return M
