local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("Gambit.lib.tree-sitter")

M.highlight_braces = function(bracket_node, destination, namespace, bufnr, hl_group)
    local opening, closing = lib_ts.get_first_and_last_bracket(bracket_node, destination)

    if opening and closing then
        ts_utils.highlight_node(opening, bufnr, namespace, hl_group)
        ts_utils.highlight_node(closing, bufnr, namespace, hl_group)
    end
end

return M
