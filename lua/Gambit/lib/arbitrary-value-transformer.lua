local M = {}

M.input_to_color = function(input)
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

M.input_to_pms_value = function(input)
    if input == "" then
        input = "0"
    end

    if tonumber(input) then
        return input .. "rem"
    end

    local _, idx = string.find(input, "%D")
    local num = tonumber(string.sub(input, 1, idx - 1))
    local chars = string.sub(input, idx)

    --stylua: ignore
    local unit_tbl = {
        x = "px", px = "px",
        p = "pt", pt = "pt",
        w = "vw", vw = "vw",
        h = "vh", vh = "vh",
    }
    return num .. unit_tbl[chars]
end

M.wrap_value_in_property = function(color, property)
    return string.format("%s-[%s]", property, color)
end

return M
