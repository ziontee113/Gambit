local module = require("Gambit")

local list = {
    { "flex" },
    { "flex", "flex-row" },
}

describe("cycle()", function()
    it("if input is empty, apply first item in list", function()
        local input = ""
        local want = "flex"
        local got = module.cycle(input, list)

        assert.equals(want, got)
    end)
    it("can cycle to the next list item", function()
        local input = "flex"
        local want = "flex flex-row"
        local got = module.cycle(input, list)

        assert.equals(want, got)
    end)
    it("can cycle to the next list item, even if input has other classes", function()
        local input = "flex text-gray-500 bg-pink-300"
        local want = "flex flex-row text-gray-500 bg-pink-300"
        local got = module.cycle(input, list)

        assert.equals(want, got)
    end)
    it("can initiate the cycle with non-empty input", function()
        local input = "text-gray-500 bg-pink-300"
        local want = "flex text-gray-500 bg-pink-300"
        local got = module.cycle(input, list)

        assert.equals(want, got)
    end)
    it("can cycle when the input classes are shuffled", function()
        local input = "text-gray-500 flex bg-pink-300"
        local want = "flex flex-row text-gray-500 bg-pink-300"
        local got = module.cycle(input, list)

        assert.equals(want, got)
    end)
end)
