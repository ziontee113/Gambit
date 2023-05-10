local M = {}

local visual_mode_active = false
local visual_elements = {}

M.activate = function()
    visual_mode_active = true
end
M.deactivate = function()
    visual_mode_active = false
    visual_elements = {}
end
M.is_active = function()
    return visual_mode_active
end
M.bracket_nodes = function()
    return visual_elements
end

M.update = function(node)
    if not visual_mode_active then
        visual_elements = {}
    end

    if not vim.tbl_contains(visual_elements, node) then
        table.insert(visual_elements, node)
    end
end

return M
