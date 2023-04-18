local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter

local M = {}

local find_parent_on_cursor = function(winnr, desired_parent_types)
    local node = ts_utils.get_node_at_cursor(winnr)

    while true do
        if not node then
            break
        end
        if vim.tbl_contains(desired_parent_types, node:type()) then
            break
        end
        node = node:parent()
    end

    return node
end

local get_first_node_matches_query = function(root, parser_name, query, target_capture_group)
    local parsed_query = ts.query.parse(parser_name, query)
    for _, matches, _ in parsed_query:iter_matches(root, 0) do
        for i, node in ipairs(matches) do
            if parsed_query.captures[i] == target_capture_group then
                return node
            end
        end
    end
end

--------------------------------------------

local get_tag_node = function(root, parser_name)
    local query = [[
        (jsx_opening_element name: (identifier) @tag)
        (jsx_self_closing_element name: (identifier) @tag)
    ]]
    return get_first_node_matches_query(root, parser_name, query, "tag")
end

local get_className_prop_identifier_node = function(root, parser_name)
    local query = [[
        (
          jsx_attribute
            (property_identifier) @prop_ident (#eq? @prop_ident "className")
        )
    ]]
    return get_first_node_matches_query(root, parser_name, query, "prop_ident")
end

local get_className_prop_string_node = function(root, parser_name)
    local query = [[
        (
          jsx_attribute
            (property_identifier) @prop_ident (#eq? @prop_ident "className")
            ((string) @className_prop_string)
        )
    ]]
    return get_first_node_matches_query(root, parser_name, query, "className_prop_string")
end

--------------------------------------------

M.get_className_prop_string_node = function(winnr)
    local jsx_element_node =
        find_parent_on_cursor(winnr, { "jsx_element", "jsx_self_closing_element" })

    if jsx_element_node then
        local tag_node = get_tag_node(jsx_element_node, "tsx")
        local className_prop_identifier_node =
            get_className_prop_identifier_node(jsx_element_node, "tsx")

        if not className_prop_identifier_node then
            local _, _, end_row, end_col = tag_node:range()
            vim.api.nvim_buf_set_text(0, end_row, end_col, end_row, end_col, { ' className=""' })
        end

        local className_prop_string_node = get_className_prop_string_node(jsx_element_node, "tsx")
        return className_prop_string_node
    end
end

return M
