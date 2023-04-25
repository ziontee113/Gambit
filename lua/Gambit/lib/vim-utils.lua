local M = {}

M.get_count = function()
    local count = vim.v.count
    if count < 1 then
        count = 1
    end
    return count
end

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

return M
