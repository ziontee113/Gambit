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

describe("replace_tailwind_color_classes", function()
    it("works", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-blue-800 flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
end)
