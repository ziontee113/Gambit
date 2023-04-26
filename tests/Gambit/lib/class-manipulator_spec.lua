local module = require("Gambit.lib.class-manipulator")

local list = {
    { "flex" },
    { "flex", "flex-row" },
}

describe("replace_classes_with_list_item()", function()
    it("adds classes correctly", function()
        local input = "text-gray-500 bg-pink-300"
        local want = "flex flex-row text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex", "flex-row" })

        assert.equals(want, got)
    end)
    it("removes classes correctly", function()
        local input = "text-gray-500 flex flex-row bg-pink-300"
        local want = "flex text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex" })

        assert.equals(want, got)
    end)
end)

describe("remove_classes_with_pattern()", function()
    it("works", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 example-400 text-center"
        local pattern = "p[xytblr]?%-%d+"

        local want = "text-gray-400 flex flex-row example-400 text-center"
        local got = module.remove_classes_with_pattern(input, pattern)
        assert.equals(want, got)
    end)
end)

describe("replace_classes_matches_pattern", function()
    it("works", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local pattern = "text%-%a+%-%d+"

        local want = "text-blue-800 flex flex-row px-20 py-10 text-center"
        local got = module.replace_first_class_matches_pattern(input, pattern, "text-blue-800")
        assert.equals(want, got)
    end)
end)
