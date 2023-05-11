local M = {}

local visual_mode = require("Gambit.lib.visual-mode")

M.wrap_selected_nodes_in_tag = function(opts)
    local start_row, end_row = visual_mode.get_start_and_end_rows()
    local lines = vim.api.nvim_buf_get_lines(opts.bufnr or 0, start_row, end_row + 1, false)

    local indent = string.match(lines[1], "^(%s*)")
    local opening_wrap = indent .. string.format("<%s>", opts.tag)
    local closing_wrap = indent .. string.format("</%s>", opts.tag)

    for i, line in ipairs(lines) do
        lines[i] = string.rep(" ", opts.indent_by) .. line
    end

    table.insert(lines, 1, opening_wrap)
    table.insert(lines, closing_wrap)

    vim.api.nvim_buf_set_lines(opts.bufnr or 0, start_row, end_row + 1, false, lines)
    vim.api.nvim_win_set_cursor(opts.winnr or 0, { start_row + 1, 0 })
    vim.cmd("norm! ^")

    visual_mode.deactivate()
    require("Gambit.api.navigation").jump_and_highlight({ direction = "in-place" })
end

return M
