local M = {}

local filter_matched_classes_in_list = function(input, list)
    local remaining_classes = vim.split(input, " ")

    for _, sub_list in ipairs(list) do
        sub_list = sub_list.classes

        for i, class in ipairs(remaining_classes) do
            if vim.tbl_contains(sub_list, class) then
                table.remove(remaining_classes, i)
            end
        end
    end

    return remaining_classes
end

local remove_empty_strings_from_tbl_then_concat_with_space = function(tbl)
    local new_tbl = {}
    for _, str in ipairs(tbl) do
        if str ~= "" then
            table.insert(new_tbl, str)
        end
    end
    return table.concat(new_tbl, " ")
end

local function append_remaining_classes(output, remaining_classes, placement)
    if placement == "after" then
        table.insert(remaining_classes, output)
    else
        table.insert(remaining_classes, 1, output)
    end
    return remove_empty_strings_from_tbl_then_concat_with_space(remaining_classes)
end

M.replace_classes_with_list_item = function(input, list, replacement, placement)
    local remaining_classes = filter_matched_classes_in_list(input, list)
    local output = table.concat(replacement, " ")
    return append_remaining_classes(output, remaining_classes, placement)
end

M.replace_tailwind_color_classes = function(input, replacements)
    local tailwind_color_patterns = {
        text = "text%-%a+%-%d+",
        bg = "bg%-%a+%-%d+",
    }
    local input_classes = vim.split(input, " ")
    local matches = {}

    for i, class in ipairs(input_classes) do
        for key, value in pairs(replacements) do
            if string.match(class, tailwind_color_patterns[key]) then
                input_classes[i] = value
                matches[key] = value
            end
        end
    end

    for key, _ in pairs(replacements) do
        if not matches[key] and replacements[key] then
            table.insert(input_classes, replacements[key])
        end
    end

    return remove_empty_strings_from_tbl_then_concat_with_space(input_classes)
end

local pms_patterns = {
    p = {
        [""] = "^p%-%d+$",
        ["x"] = "^px%-%d+$",
        ["y"] = "^py%-%d+$",
        ["t"] = "^pt%-%d+$",
        ["b"] = "^pb%-%d+$",
        ["l"] = "^pl%-%d+$",
        ["r"] = "^pr%-%d+$",
        ["all"] = "^p[xytblr]?%-%d+$",
    },
    m = {
        [""] = "^m%-%d+$",
        ["x"] = "^mx%-%d+$",
        ["y"] = "^my%-%d+$",
        ["t"] = "^mt%-%d+$",
        ["b"] = "^mb%-%d+$",
        ["l"] = "^ml%-%d+$",
        ["r"] = "^mr%-%d+$",
        ["all"] = "^m[xytblr]?%-%d+$",
    },
    ["space-"] = {
        ["x"] = "^space%-x%-%d+$",
        ["y"] = "^space%-y%-%d+$",
        ["all"] = "^space%-[xy]?%-%d+$",
    },
}

M.replace_pms_classes = function(input, property, axis, replacement)
    local input_classes = vim.split(input, " ")
    local replaced = false

    for i, class in ipairs(input_classes) do
        if string.match(class, pms_patterns[property][axis]) then
            if not replaced then
                input_classes[i] = replacement
                replaced = true
            else
                input_classes[i] = ""
            end
        end
    end

    if not replaced then
        table.insert(input_classes, replacement)
    end

    return remove_empty_strings_from_tbl_then_concat_with_space(input_classes)
end

M.remove_pms_classes = function(input, property, axies_to_remove)
    if type(axies_to_remove) == "string" then
        axies_to_remove = { axies_to_remove }
    end
    if not axies_to_remove or #axies_to_remove == 0 then
        return input
    end

    local input_classes = vim.split(input, " ")

    for i, class in ipairs(input_classes) do
        for _, axis in ipairs(axies_to_remove) do
            if string.match(class, pms_patterns[property][axis]) then
                input_classes[i] = ""
            end
        end
    end

    return remove_empty_strings_from_tbl_then_concat_with_space(input_classes)
end

return M
