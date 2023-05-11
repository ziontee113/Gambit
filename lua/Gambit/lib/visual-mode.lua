local lib_ts = require("Gambit.lib.tree-sitter")

local M = {}
local ns = vim.api.nvim_create_namespace("stormcaller_visual_mode")

local visual_mode_active = false
local visual_elements = {}

local update_eol_extmarks = function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    if visual_mode_active then
        for _, node in ipairs(visual_elements) do
            local start_row = node:range()
            vim.api.nvim_buf_set_extmark(0, ns, start_row, 0, {
                virt_text = { { "V", "@attribute" } },
                virt_text_pos = "eol",
            })
        end
    end
end

M.activate = function()
    visual_mode_active = true
    update_eol_extmarks()
end
M.deactivate = function()
    visual_mode_active = false
    visual_elements = {}
    update_eol_extmarks()
end

M.is_active = function()
    return visual_mode_active
end
M.jsx_nodes = function()
    return visual_elements
end

M.get_start_and_end_rows = function()
    local start1, _, end1, _ = visual_elements[1]:range()
    local start2, _, end2, _ = visual_elements[#visual_elements]:range()

    local start_row, end_row
    if start1 < start2 then
        start_row, end_row = start1, end2
    else
        start_row, end_row = start2, end1
    end

    return start_row, end_row
end

M.update = function(node, winnr)
    if visual_mode_active == false then
        visual_elements = {}
    end

    local jsx_node = lib_ts.get_updated_jsx_node(winnr, node)
    if not jsx_node then
        return
    end

    if not vim.tbl_contains(visual_elements, jsx_node) then
        if #visual_elements == 0 then
            table.insert(visual_elements, jsx_node)
        elseif jsx_node:parent() == visual_elements[1]:parent() then
            table.insert(visual_elements, jsx_node)
        end
    end

    update_eol_extmarks()
end

M.change_selected_elements_classes = function(callback, change_arguments)
    for i, node in ipairs(visual_elements) do
        change_arguments.node = node
        callback(change_arguments)

        visual_elements[i] = lib_ts.get_updated_jsx_node(change_arguments.winnr, node)
    end
end

return M
