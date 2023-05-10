local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

M.replace_all_classes_to_sibling_classes = function()
    local className_string_node, jsx_tag_node = lib_ts.get_tag_and_className_string_nodes(winnr)
    local old_classes = lib_ts.get_classes_from_className_string_node(className_string_node, bufnr)
end

return M
