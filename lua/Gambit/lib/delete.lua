local M = {}

local visual_mode = require("Gambit.lib.visual-mode")

M.delete = function(winnr, bufnr)
    local start_row, end_row = visual_mode.get_start_and_end_rows()

    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
    vim.api.nvim_win_set_cursor(winnr, { start_row + 1, 0 })
    vim.cmd("norm! ^")

    visual_mode.deactivate()
end

return M
