local M = {}

local find_matching_list = function(input, list)
    local input_classes = vim.split(input, " ")

    local remaining_classes = {}
    local highest_score, return_index = 0, 0

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
        if score == #sub_list and score > highest_score then
            highest_score, return_index = score, list_index
        end
    end

    return return_index, remaining_classes
end

local function append_remaining_classes(output, remaining_classes)
    local joined_remaining_classes = table.concat(remaining_classes, " ")
    if joined_remaining_classes ~= "" then
        output = string.format("%s %s", output, joined_remaining_classes)
    end
    return output
end

M.cycle_class_list = function(input, list)
    local matched_list_index, remaining_classes = find_matching_list(input, list)

    local next_index = matched_list_index + 1
    if next_index > #list then
        next_index = 1
    end

    local output = table.concat(list[next_index], " ")
    return append_remaining_classes(output, remaining_classes)
end

M.replace_classes = function(input, list, replacement)
    local _, remaining_classes = find_matching_list(input, list)
    local output = table.concat(replacement, " ")
    return append_remaining_classes(output, remaining_classes)
end

M.remove_all_classes = function(input, pattern)
    local input_classes = vim.split(input, " ")
    local remaining_classes = {}

    for _, class in ipairs(input_classes) do
        if not string.match(class, pattern) then
            table.insert(remaining_classes, class)
        end
    end

    return table.concat(remaining_classes, " ")
end

return M
