local M = {}

M.transform = function(input)
    local _, commas = string.gsub(input, ",", "")
    if commas > 0 then
        if commas == 3 then
            return string.format("rgba(%s%%)", input)
        else
            return string.format("rgb(%s)", input)
        end
    end

    local _, dots = string.gsub(input, ".", "")
    if dots > 0 then
        local split = vim.split(input, "%.")
        if #split == 3 then
            return string.format("hsl(%s,%s%%,%s%%)", unpack(split))
        elseif #split == 4 then
            return string.format("hsla(%s,%s%%,%s%%,%s%%)", unpack(split))
        end
    end

    return string.format("#%s", input)
end

return M
