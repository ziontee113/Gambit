local ts_utils = require("nvim-treesitter.ts_utils")
local vim_utils = require("Gambit.lib.vim-utils")
local ts = vim.treesitter

local M = {}

M.find_parent = function(winnr, desired_parent_types, node)
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

M.get_children_nodes = function(parent)
    local nodes = {}
    for node in parent:iter_children() do
        table.insert(nodes, node)
    end
    return nodes
end

M.get_root = function(parser_name)
    local parser_ok, parser = pcall(vim.treesitter.get_parser, 0, parser_name)

    if parser_ok then
        local trees = parser:parse()
        local root = trees[1]:root()

        return root
    end
end

M.get_all_nodes_matches_query = function(query, parser_name, root, capture_groups)
    local nodes = {}

    local grouped_nodes = {}
    for _, key in ipairs(capture_groups or {}) do
        grouped_nodes[key] = {}
    end

    root = root or M.get_root(parser_name)
    local parsed_query = ts.query.parse(parser_name, query)

    for _, matches, _ in parsed_query:iter_matches(root, 0) do
        for i, node in ipairs(matches) do
            table.insert(nodes, node)

            if capture_groups then
                local capture_group_name = parsed_query.captures[i]
                if vim.tbl_contains(capture_groups, capture_group_name) then
                    table.insert(grouped_nodes[capture_group_name], node)
                end
            end
        end
    end

    return nodes, grouped_nodes
end

M.get_children_that_matches_types = function(node, desired_children_types)
    local matched_tbl = {}

    for child in node:iter_children() do
        for _, desired_type in ipairs(desired_children_types) do
            if child:type() == desired_type then
                table.insert(matched_tbl, child)
            end
        end
    end

    return matched_tbl
end

-------------------------------------------- for Cosmic Cursor and Cosmic Rays

M.get_jsx_parent_of_bracket = function(bracket)
    if
        bracket:type() == "jsx_element"
        or bracket:type() == "jsx_self_closing_element"
        or bracket:type() == "jsx_fragment"
    then
        return bracket
    end

    local parent = bracket:parent()
    if parent:type() == "jsx_self_closing_element" or parent:type() == "jsx_fragment" then
        return parent
    end

    return parent:parent()
end

local get_opening_and_closing_brackets = function(node)
    local opening_brackets = M.get_all_nodes_matches_query(
        [[
("<" @bracket (#has-ancestor? @bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx",
        node
    )
    local closing_brackets = M.get_all_nodes_matches_query(
        [[
(">" @bracket (#has-ancestor? @bracket jsx_element jsx_self_closing_element jsx_fragment))
    ]],
        "tsx",
        node
    )

    return opening_brackets, closing_brackets
end

M.get_first_and_last_bracket = function(bracket_node, destination)
    local jsx_parent = M.get_jsx_parent_of_bracket(bracket_node)
    local opening_brackets, closing_brackets = get_opening_and_closing_brackets(jsx_parent)

    if #opening_brackets == 0 or #closing_brackets == 0 then
        return
    end

    local opening, closing
    if destination == "next-to" then
        opening = opening_brackets[1]
        closing = closing_brackets[#closing_brackets]
    elseif destination == "inside" then
        opening = closing_brackets[1]
        closing = opening_brackets[#opening_brackets]
    end

    return opening, closing
end

--------------------------------------------

M.find_attribute_root = function(jsx_node)
    local root
    if jsx_node:type() == "jsx_element" then
        local opening_element =
            M.get_children_that_matches_types(jsx_node, { "jsx_opening_element" })[1]
        root = opening_element
    elseif jsx_node:type() == "jsx_self_closing_element" then
        root = jsx_node
    end
    return root
end

M.get_tag_and_className_string_nodes = function(winnr, node)
    local desired_types = { "jsx_element", "jsx_self_closing_element" }
    local jsx_node = M.find_parent(winnr, desired_types, node)
    local root = M.find_attribute_root(jsx_node)

    local _, matched_groups = M.get_all_nodes_matches_query(
        [[ ;query
(jsx_attribute
  (property_identifier) @prop_ident (#eq? @prop_ident "className")
  (string) @string
)
]],
        "tsx",
        root,
        { "string" }
    )

    local jsx_tag_node = M.get_children_that_matches_types(root, { "identifier" })[1]
    local className_string_node = matched_groups["string"][1]

    return className_string_node, jsx_tag_node
end

M.get_classes_from_className_string_node = function(className_string_node, bufnr)
    local old_classes = ""
    if className_string_node then
        old_classes = vim.treesitter.get_node_text(className_string_node, bufnr)
        old_classes = string.gsub(old_classes, "^[\"']", "")
        old_classes = string.gsub(old_classes, "[\"']$", "")
    end

    return old_classes
end

--------------------------------------------

local desired_parent_types = { "jsx_element", "jsx_self_closing_element" }
M.get_updated_jsx_node = function(winnr, og_node)
    local root = M.get_root("tsx")
    local start_row, start_col = og_node:range()

    local node = root:named_descendant_for_range(start_row, start_col, start_row, start_col)
    local jsx_node = M.find_parent(winnr, desired_parent_types, node)
    return jsx_node
end

--------------------------------------------

M.replace_node_text = function(bufnr, node, replacement)
    replacement = vim_utils.string_to_string_tbl(replacement)

    local start_row, start_col, end_row, end_col = node:range()
    vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, replacement)
end

return M
