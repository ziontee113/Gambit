local M = {}

local find_matching_list = function(input, list)
    local input_classes = vim.split(input, " ")
    local remaining_classes = {}

    for list_index, sub_list in ipairs(list) do
        local score = 0
        remaining_classes = {}
        for _, input_class in ipairs(input_classes) do
            if vim.tbl_contains(sub_list, input_class) then
                score = score + 1
            else
                table.insert(remaining_classes, input_class)
            end
        end
        if score == #sub_list then
            return list_index, remaining_classes
        end
    end

    return nil, remaining_classes
end

M.cycle = function(input, list)
    local matched_list_index, remaining_classes = find_matching_list(input, list)

    local next_index = (matched_list_index or 0) + 1
    if next_index > #list then
        next_index = 1
    end

    local output = table.concat(list[next_index], " ")

    local old_remaining_classes = table.concat(remaining_classes, " ")
    if old_remaining_classes ~= "" then
        output = string.format("%s %s", output, old_remaining_classes)
    end

    return output
end

return M
