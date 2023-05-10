local M = {}

local visual_mode = require("Gambit.lib.visual-mode")

M.delete = function(winnr, bufnr)
    local nodes = visual_mode.jsx_nodes()

    local start1, _, end1, _ = nodes[1]:range()
    local start2, _, end2, _ = nodes[#nodes]:range()

    local start_row, end_row
    if start1 < start2 then
        start_row, end_row = start1, end2
    else
        start_row, end_row = start2, end1
    end

    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
    vim.api.nvim_win_set_cursor(winnr, { start_row + 1, 0 })
    vim.cmd("norm! ^")

    visual_mode.deactivate()
end

return M
