local M = {}

local filter_matched_classes_in_list = function(input, list)
    local input_classes = vim.split(input, " ")

    local remaining_classes = {}
    local highest_score = 0
    local matched_index = 0

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
            highest_score = score
            matched_index = list_index
        end
    end

    return remaining_classes, matched_index, input_classes
end

local function append_remaining_classes(output, remaining_classes)
    local joined_remaining_classes = table.concat(remaining_classes, " ")
    if joined_remaining_classes ~= "" then
        output = string.format("%s %s", output, joined_remaining_classes)
    end
    return output
end

M.replace_classes_with_list_item = function(input, list, replacement)
    local remaining_classes = filter_matched_classes_in_list(input, list)
    local output = table.concat(replacement, " ")
    return append_remaining_classes(output, remaining_classes)
end

M.replace_tailwind_color_classes = function(input, replacements)
    local tailwind_patterns = {
        text = "text%-%a+%-%d+",
        bg = "bg%-%a+%-%d+",
    }
    local input_classes = vim.split(input, " ")
    local matches = {}

    for i, class in ipairs(input_classes) do
        for type, pattern in pairs(tailwind_patterns) do
            if string.match(class, pattern) then
                input_classes[i] = replacements[type]
                matches[type] = replacements[type]
            end
        end
    end

    for type, _ in pairs(replacements) do
        if not matches[type] and replacements[type] then
            table.insert(input_classes, replacements[type])
        end
    end

    local new_classes = {}
    for _, class in ipairs(input_classes) do
        if class ~= "" then
            table.insert(new_classes, class)
        end
    end

    return table.concat(new_classes, " ")
end

return M
