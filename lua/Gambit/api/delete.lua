local M = {}

local visual_mode = require("Gambit.lib.visual-mode")

M.delete_tags = function(opts)
    local start_row, end_row = visual_mode.get_start_and_end_rows()

    vim.api.nvim_buf_set_lines(opts.bufnr or 0, start_row, end_row + 1, false, {})
    vim.api.nvim_win_set_cursor(opts.winnr or 0, { start_row + 1, 0 })
    vim.cmd("norm! ^")

    visual_mode.deactivate()
    require("Gambit.api.navigation").jump_and_highlight({ direction = "in-place" })
end

return M
