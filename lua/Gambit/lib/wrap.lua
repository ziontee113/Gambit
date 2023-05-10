local M = {}

local visual_mode = require("Gambit.lib.visual-mode")

M.wrap_selected_nodes_in_tag = function(tag, winnr, bufnr, indent_by)
    local start_row, end_row = visual_mode.get_start_and_end_rows()
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

    local indent = string.match(lines[1], "^(%s*)")
    local opening_wrap = indent .. string.format("<%s>", tag)
    local closing_wrap = indent .. string.format("</%s>", tag)

    for i, line in ipairs(lines) do
        lines[i] = string.rep(" ", indent_by) .. line
    end

    table.insert(lines, 1, opening_wrap)
    table.insert(lines, closing_wrap)

    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, lines)
    vim.api.nvim_win_set_cursor(winnr, { start_row + 1, 0 })
    vim.cmd("norm! ^")

    visual_mode.deactivate()
end

return M
