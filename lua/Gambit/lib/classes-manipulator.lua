local M = {}
local lua_patterns = require("Gambit.lua_patterns")

local filter_matched_classes_in_list = function(input, list)
    local remaining_classes = vim.split(input, " ")

    for _, sub_list in ipairs(list) do
        sub_list = sub_list.classes

        for i = #remaining_classes, 1, -1 do
            if vim.tbl_contains(sub_list, remaining_classes[i]) then
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

local remove_negative_classes = function(classes, negatives)
    for i = #classes, 1, -1 do
        for _, pattern_set in ipairs(negatives) do
            for _, pattern in ipairs(pattern_set) do
                if classes[i] and string.match(classes[i], pattern) then
                    table.remove(classes, i)
                    break
                end
            end
        end
    end
    return classes
end

local add_pseudo_classes = function(replacement)
    return PSEUDO_CLASSES .. replacement
end

M.replace_classes_with_list_item = function(input, list, replacement, placement, negatives)
    local remaining_classes = filter_matched_classes_in_list(input, list)
    remaining_classes = remove_negative_classes(remaining_classes, negatives or {})

    local output = table.concat(replacement, " ")
    return append_remaining_classes(output, remaining_classes, placement)
end

M.replace_tailwind_color_classes = function(input, replacements)
    for key, value in pairs(replacements) do
        replacements[key] = add_pseudo_classes(value)
    end

    local tailwind_color_patterns = {
        text = lua_patterns.text_color,
        bg = lua_patterns.background_color,
    }
    local input_classes = vim.split(input, " ")
    local matches = {}

    for i, class in ipairs(input_classes) do
        for key, value in pairs(replacements) do
            for _, pattern in ipairs(tailwind_color_patterns[key]) do
                if string.match(class, pattern) and string.find(class, PSEUDO_CLASSES, 1, true) then
                    input_classes[i] = value
                    matches[key] = value
                    break
                end
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
        [""] = { "^.*:p%-%d+$", "^p%-%d+$" },
        ["x"] = { "^.*:px%-%d+$", "^px%-%d+$" },
        ["y"] = { "^.*:py%-%d+$", "^py%-%d+$" },
        ["t"] = { "^.*:pt%-%d+$", "^pt%-%d+$" },
        ["b"] = { "^.*:pb%-%d+$", "^pb%-%d+$" },
        ["l"] = { "^.*:pl%-%d+$", "^pl%-%d+$" },
        ["r"] = { "^.*:pr%-%d+$", "^pr%-%d+$" },
        ["all"] = { "^.*:p[xytblr]?%-%d+$", "^p[xytblr]?%-%d+$" },
    },
    m = {
        [""] = { "^.*:m%-%d+$", "^m%-%d+$" },
        ["x"] = { "^.*:mx%-%d+$", "^mx%-%d+$" },
        ["y"] = { "^.*:my%-%d+$", "^my%-%d+$" },
        ["t"] = { "^.*:mt%-%d+$", "^mt%-%d+$" },
        ["b"] = { "^.*:mb%-%d+$", "^mb%-%d+$" },
        ["l"] = { "^.*:ml%-%d+$", "^ml%-%d+$" },
        ["r"] = { "^.*:mr%-%d+$", "^mr%-%d+$" },
        ["all"] = { "^.*:m[xytblr]?%-%d+$", "^m[xytblr]?%-%d+$" },
    },
    ["space-"] = {
        ["x"] = { "^.*:space%-x%-%d+$", "^space%-x%-%d+$" },
        ["y"] = { "^.*:space%-y%-%d+$", "^space%-y%-%d+$" },
        ["all"] = { "^.*:space%-[xy]?%-%d+$", "^space%-[xy]?%-%d+$" },
    },
}

M.replace_pms_classes = function(input, property, axis, replacement)
    replacement = add_pseudo_classes(replacement)

    local input_classes = vim.split(input, " ")
    local replaced = false

    for i, class in ipairs(input_classes) do
        for _, pattern in ipairs(pms_patterns[property][axis]) do
            if string.match(class, pattern) then
                if not replaced then
                    if string.find(input_classes[i], PSEUDO_CLASSES, 1, true) then
                        input_classes[i] = replacement
                        replaced = true
                    end
                else
                    if string.find(input_classes[i], PSEUDO_CLASSES, 1, true) then
                        input_classes[i] = ""
                    end
                end
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
            for _, pattern in ipairs(pms_patterns[property][axis]) do
                if string.match(class, pattern) and string.find(class, PSEUDO_CLASSES, 1, true) then
                    input_classes[i] = ""
                end
            end
        end
    end

    return remove_empty_strings_from_tbl_then_concat_with_space(input_classes)
end

return M
