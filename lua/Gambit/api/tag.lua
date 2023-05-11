local M = {}

local cosmic_creation = require("Gambit.lib.cosmic-creation")
local navigation = require("Gambit.api.navigation")

local previous_add_tag_args

M.new = function(tag, enter)
    local count = require("Gambit.lib.vim-utils").get_count()
    local added_new_lines =
        cosmic_creation.create_tag_at_cursor(tag, navigation._destination(), count)

    -- update cursor position to the newly created tag
    if added_new_lines then
        vim.cmd("norm! k")
    else
        local jump_cmd = "norm! " .. count .. "j"
        vim.cmd(jump_cmd)
    end
    vim.cmd("norm! ^")

    -- update destination for future tags base on `enter` argument
    local destination = enter and "inside" or "next-to"
    navigation._update_destination(destination)

    -- update the highlighting
    navigation.jump_and_highlight({ direction = "in-place" })

    GAMBIT_PREVIOUS_ACTION = "add-tag"
    previous_add_tag_args = { tag, enter }
end

M.repeat_previous_action = function()
    M.new(unpack(previous_add_tag_args))
end

return M
