local transformer = require("Gambit.lib.arbitrary-color-transformer")

describe("input_to_color()", function()
    it("transforms input with 2 comma separated numbers to rgb()", function()
        local input = "222,11,0"
        local want = "rgb(222,11,0)"
        local got = transformer.input_to_color(input)
        assert.equals(want, got)
    end)
    it("transforms input with 3 comma separated numbers to rgba()", function()
        local input = "222,11,0,10"
        local want = "rgba(222,11,0,10%)"
        local got = transformer.input_to_color(input)
        assert.equals(want, got)
    end)

    it("transforms input with 2 dots separated numbers to hsl()", function()
        local input = "222.11.10"
        local want = "hsl(222,11%,10%)"
        local got = transformer.input_to_color(input)
        assert.equals(want, got)
    end)
    it("transforms input with 3 dots separated numbers to hsla()", function()
        local input = "222.11.10.10"
        local want = "hsla(222,11%,10%,10%)"
        local got = transformer.input_to_color(input)
        assert.equals(want, got)
    end)

    it("transforms input with no comma or dot to hex color", function()
        local input = "000"
        local want = "#000"
        local got = transformer.input_to_color(input)
        assert.equals(want, got)
    end)
end)
