local M = {}

local cosmic_cursor = require("Gambit.lib.cosmic-cursor")
local cosmic_rays = require("Gambit.lib.cosmic-rays")

local ns = vim.api.nvim_create_namespace("stormcaller_navigation")
M._clear_namespace = function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local destination = "next-to"
M._destination = function()
    return destination
end
M._update_destination = function(value)
    destination = value
end

M.jump_and_highlight = function(opts)
    local count = require("Gambit.lib.vim-utils").get_count()

    for _ = 1, count do
        local target_node = cosmic_cursor.jump({
            direction = opts.direction,
            destination = destination,
            skip_visual_mode = opts.skip_visual_mode,
            winnr = 0,
        })
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        cosmic_rays.highlight_braces(target_node, destination, ns, 0, opts.hl_group or "DiffText")
    end
end

M.jump_and_highlight_sibling = function(direction, hl_group)
    local count = require("Gambit.lib.vim-utils").get_count()

    for _ = 1, count do
        local sibling = cosmic_cursor.jump_to_jsx_relative(0, direction)
        if sibling then
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
            cosmic_rays.highlight_braces(sibling, destination, ns, 0, hl_group or "DiffText")
        end
    end
end

M.toggle_inside_or_outside_opt = function()
    if destination == "next-to" then
        destination = "inside"
    else
        destination = "next-to"
    end

    M.jump_and_highlight({ direction = "previous" })
    M.jump_and_highlight({ direction = "next" })
end

return M
