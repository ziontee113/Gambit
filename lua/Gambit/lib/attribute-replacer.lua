local M = {}

local lib_ts = require("Gambit.lib.tree-sitter")

M.replace_attribute_with_empty_jsx_expression = function(opts)
    local desired_types = { "jsx_element", "jsx_self_closing_element" }
    local jsx_node = lib_ts.find_parent(opts.winnr, desired_types, opts.node)
    local attr_root = lib_ts.find_attribute_root(jsx_node)

    local query = string.format(
        [[ ;query
(jsx_attribute
  (property_identifier) @prop_ident (#eq? @prop_ident "%s")
) ]],
        opts.attribute
    )

    local _, matched_identifiers =
        lib_ts.get_all_nodes_matches_query(query, "tsx", attr_root, { "prop_ident" })
    local property_identifier = matched_identifiers["prop_ident"][1]

    local replacement = { "{}" }
    local jump_to_row, jump_to_col

    if property_identifier then
        local property_node = property_identifier:next_named_sibling()
        lib_ts.replace_node_text(opts.bufnr, property_node, replacement)

        local start_row, start_col = property_node:range()
        jump_to_row = start_row + 1
        jump_to_col = start_col
    else
        local jsx_tag_node = lib_ts.get_children_that_matches_types(attr_root, { "identifier" })[1]
        local _, _, end_row, end_col = jsx_tag_node:range()

        replacement = { string.format(" %s={}", opts.attribute) }
        vim.api.nvim_buf_set_text(opts.bufnr, end_row, end_col, end_row, end_col, replacement)

        jump_to_row = end_row + 1
        jump_to_col = end_col
    end

    vim.api.nvim_win_set_cursor(opts.winnr, { jump_to_row, jump_to_col })
    vim.api.nvim_feedkeys("a", "ni!", false)
end

return M
