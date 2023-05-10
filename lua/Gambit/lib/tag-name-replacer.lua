local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")
local visual_mode = require("Gambit.lib.visual-mode")

M.replace_to = function(opts)
    for _, node in ipairs(visual_mode.jsx_nodes()) do
        if node:type() == "jsx_element" then
            local opening_query = [[ (jsx_opening_element name: (identifier) @cap) ]]
            local opening_idents =
                lib_ts.get_all_nodes_matches_query(opening_query, "tsx", node, { "ident" })

            local closing_query = [[ (jsx_closing_element name: (identifier) @cap) ]]
            local closing_idents =
                lib_ts.get_all_nodes_matches_query(closing_query, "tsx", node, { "ident" })

            lib_ts.replace_node_text(opts.bufnr, closing_idents[#closing_idents], { opts.tag })
            lib_ts.replace_node_text(opts.bufnr, opening_idents[1], { opts.tag })
        elseif node:type() == "jsx_self_closing_element" then
            local opening_query = [[ (jsx_self_closing_element name: (identifier) @cap) ]]
            local opening_idents =
                lib_ts.get_all_nodes_matches_query(opening_query, "tsx", node, { "ident" })
            lib_ts.replace_node_text(opts.bufnr, opening_idents[1], { opts.tag })
        end
    end

    visual_mode.deactivate()
end

return M
