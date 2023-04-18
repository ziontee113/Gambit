local module = require("Gambit")

local list = {
    { "" },
    { "flex" },
    { "flex flex-row" },
}

describe("module", function()
    it("works", function()
        local input = ""
        local want = "flex"
        local got = module.slice(input, list)

        assert.equals(want, got)
    end)
end)
