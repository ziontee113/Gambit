local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter

local M = {}

M.find_parent_on_cursor = function(winnr, desired_parent_types, node)
    node = node or ts_utils.get_node_at_cursor(winnr)

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

local get_node_matches_query = function(root, parser_name, query, target_capture_group, item_order)
    item_order = item_order or "first"
    local node_to_return

    local parsed_query = ts.query.parse(parser_name, query)
    for _, matches, _ in parsed_query:iter_matches(root, 0) do
        for i, node in ipairs(matches) do
            if item_order == "first" then
                if parsed_query.captures[i] == target_capture_group then
                    return node
                end
            elseif item_order == "last" then
                node_to_return = node
            end
        end
    end

    return node_to_return
end

local get_root = function(parser_name)
    local parser_ok, parser = pcall(vim.treesitter.get_parser, 0, parser_name)

    if parser_ok then
        local trees = parser:parse()
        local root = trees[1]:root()

        return root
    end
end

M.get_all_nodes_matches_query = function(query, parser_name)
    local nodes = {}

    local root = get_root(parser_name)
    local parsed_query = ts.query.parse(parser_name, query)

    for _, matches, _ in parsed_query:iter_matches(root, 0) do
        for _, node in ipairs(matches) do
            table.insert(nodes, node)
        end
    end

    return nodes
end

--------------------------------------------

local get_tag_node = function(root, parser_name)
    local query = [[
        (jsx_opening_element name: (identifier) @tag)
        (jsx_self_closing_element name: (identifier) @tag)
    ]]
    return get_node_matches_query(root, parser_name, query, "tag")
end

local get_className_prop_identifier_node = function(root, parser_name)
    local query = [[
        (
          jsx_attribute
            (property_identifier) @prop_ident (#eq? @prop_ident "className")
        )
    ]]
    return get_node_matches_query(root, parser_name, query, "prop_ident")
end

local get_className_prop_string_node = function(root, parser_name)
    local query = [[
        (
          jsx_attribute
            (property_identifier) @prop_ident (#eq? @prop_ident "className")
            ((string) @className_prop_string)
        )
    ]]
    return get_node_matches_query(root, parser_name, query, "className_prop_string")
end

--------------------------------------------

M.get_className_related_nodes = function(winnr)
    local jsx_element_node =
        M.find_parent_on_cursor(winnr, { "jsx_element", "jsx_self_closing_element" })

    if jsx_element_node then
        local tag_node = get_tag_node(jsx_element_node, "tsx")
        local className_prop_identifier_node =
            get_className_prop_identifier_node(jsx_element_node, "tsx")
        local className_prop_string_node = get_className_prop_string_node(jsx_element_node, "tsx")

        return tag_node, className_prop_identifier_node, className_prop_string_node
    end
end

M.get_opening_and_closing_tag_nodes = function(winnr)
    local jsx_element_node =
        M.find_parent_on_cursor(winnr, { "jsx_element", "jsx_self_closing_element" })

    local opening_query = [[
        (jsx_opening_element name: (identifier) @tag)
        (jsx_self_closing_element name: (identifier) @tag)
    ]]
    local opening_node = get_node_matches_query(jsx_element_node, "tsx", opening_query, "tag")

    local closing_query = [[
        (jsx_closing_element name: (identifier) @tag)
    ]]
    local closing_node =
        get_node_matches_query(jsx_element_node, "tsx", closing_query, "tag", "last")

    return opening_node, closing_node
end

--------------------------------------------

M.string_to_string_tbl = function(str)
    if type(str) == "string" then
        if string.match(str, "\n") then
            str = vim.split(str, "\n")
        else
            str = { str }
        end
    end
    return str
end

M.repend_rowlace_node_text = function(bufnr, node, replacement)
    replacement = M.string_to_string_tbl(replacement)

    local start_row, start_col, end_row, end_col = node:range()
    vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, replacement)
end

return M
