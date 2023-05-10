local M = {}

local visual_mode = require("Gambit.lib.visual-mode")
local lib_ts = require("Gambit.lib.tree-sitter")

M.delete = function(winnr, bufnr)
    local parent_types = { "jsx_element", "jsx_self_closing_element" }
    for _, bracket in ipairs(visual_mode.bracket_nodes()) do
        local jsx_node = lib_ts.find_parent(winnr, parent_types, bracket)
        lib_ts.replace_node_text(bufnr, jsx_node, "")
        vim.cmd("norm! ddk")
    end
end

return M
