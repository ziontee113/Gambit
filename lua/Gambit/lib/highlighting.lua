local M = {}
local ts_utils = require("nvim-treesitter.ts_utils")
local lib_ts = require("Gambit.lib.tree-sitter")

M.highlight_tag_indicators = function(namespace)
    namespace = namespace or 0

    local opening_tag_node, closing_tag_node = lib_ts.get_opening_and_closing_tag_nodes(0)

    if opening_tag_node then
        ts_utils.highlight_node(opening_tag_node, 0, namespace, "CurSearch")
    end
    if closing_tag_node then
        ts_utils.highlight_node(closing_tag_node, 0, namespace, "CurSearch")
    end
end

return M
