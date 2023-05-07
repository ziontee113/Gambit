local M = {}
local lua_patterns = require("Gambit.lua_patterns")

local add_pseudo_classes = function(replacement)
    if replacement ~= "" then
        return PSEUDO_CLASSES .. replacement
    end
    return replacement
end

local pseudo_split = function(class)
    local pseudo_prefix, style = string.match(class, lua_patterns.pseudo_splitter)
    if not style then
        style = class
        pseudo_prefix = ""
    end
    return pseudo_prefix, style
end

local filter_matched_classes_in_list = function(input, list)
    local remaining_classes = vim.split(input, " ")

    for _, sub_list in ipairs(list) do
        sub_list = sub_list.classes
        for i, _ in ipairs(sub_list) do
            sub_list[i] = add_pseudo_classes(sub_list[i])
        end

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

M.replace_classes_with_list_item = function(input, list, replacement, placement, negatives)
    local remaining_classes = filter_matched_classes_in_list(input, list)
    remaining_classes = remove_negative_classes(remaining_classes, negatives or {})

    for i, _ in ipairs(replacement) do
        replacement[i] = add_pseudo_classes(replacement[i])
    end
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
                local pseudo_prefix, style = pseudo_split(class)

                print(pseudo_prefix, style, PSEUDO_CLASSES)

                if string.match(style, pattern) and (pseudo_prefix == PSEUDO_CLASSES) then
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

local pms_patterns = lua_patterns.pms_patterns
M.replace_pms_classes = function(input, property, axis, replacement)
    replacement = add_pseudo_classes(replacement)

    local input_classes = vim.split(input, " ")
    local replaced = false

    for i, class in ipairs(input_classes) do
        local pseudo_prefix, style = pseudo_split(class)

        if string.match(style, pms_patterns[property][axis]) then
            if pseudo_prefix == PSEUDO_CLASSES then
                if not replaced then
                    input_classes[i] = replacement
                    replaced = true
                else
                    input_classes[i] = ""
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
        local pseudo_prefix, style = pseudo_split(class)
        for _, axis in ipairs(axies_to_remove) do
            if
                string.match(style, pms_patterns[property][axis])
                and pseudo_prefix == PSEUDO_CLASSES
            then
                input_classes[i] = ""
            end
        end
    end

    return remove_empty_strings_from_tbl_then_concat_with_space(input_classes)
end

return M
