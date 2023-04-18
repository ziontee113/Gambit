local module = require("Gambit.lib.class-manipulator")

local list = {
    { "flex" },
    { "flex", "flex-row" },
}

describe("cycle_class_list()", function()
    it("if input is empty, apply first item in list", function()
        local input = ""
        local want = "flex"
        local got = module.cycle_class_list(input, list)

        assert.equals(want, got)
    end)
    it("can cycle to the next list item", function()
        local input = "flex"
        local want = "flex flex-row"
        local got = module.cycle_class_list(input, list)

        assert.equals(want, got)
    end)
    it("can cycle to the next list item, even if input has other classes", function()
        local input = "flex text-gray-500 bg-pink-300"
        local want = "flex flex-row text-gray-500 bg-pink-300"
        local got = module.cycle_class_list(input, list)

        assert.equals(want, got)
    end)
    it("can initiate the cycle with non-empty input", function()
        local input = "text-gray-500 bg-pink-300"
        local want = "flex text-gray-500 bg-pink-300"
        local got = module.cycle_class_list(input, list)

        assert.equals(want, got)
    end)
    it("can cycle when the input classes are shuffled", function()
        local input = "text-gray-500 flex bg-pink-300"
        local want = "flex flex-row text-gray-500 bg-pink-300"
        local got = module.cycle_class_list(input, list)

        assert.equals(want, got)
    end)
end)

describe("remove_all_classes()", function()
    it("works", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 example-400 text-center"
        local pattern = "p[xytblr]?%-%d+"

        local want = "text-gray-400 flex flex-row example-400 text-center"
        local got = module.remove_all_classes(input, pattern)
        assert.equals(want, got)
    end)
end)
