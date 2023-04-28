local module = require("Gambit.lib.classes-manipulator")

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
    it("adds correctly", function()
        local input = "flex flex-row px-20 py-10 text-center"
        local want = "flex flex-row px-20 py-10 text-center text-blue-800"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("replaces correctly", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-blue-800 flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("adds and replaces correctly", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-blue-800 flex flex-row px-20 py-10 text-center bg-gray-100"
        local got = module.replace_tailwind_color_classes(
            input,
            { text = "text-blue-800", bg = "bg-gray-100" }
        )
        assert.equals(want, got)
    end)
end)

describe("replace_tailwind_padding_classes", function()
    it("adds correctly for omni axis", function()
        local input = "flex flex-row text-center"
        local want = "flex flex-row text-center p-4"
        local got = module.replace_tailwind_padding_classes(input, "", "p-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for omni axis", function()
        local input = "text-gray-400 flex flex-row p-20 text-center"
        local want = "text-gray-400 flex flex-row p-4 text-center"
        local got = module.replace_tailwind_padding_classes(input, "", "p-4")
        assert.equals(want, got)
    end)
    it("removes correctly for omni axis", function()
        local input = "text-gray-400 flex flex-row p-20 text-center"
        local want = "text-gray-400 flex flex-row text-center"
        local got = module.replace_tailwind_padding_classes(input, "", "")
        assert.equals(want, got)
    end)

    it("adds correctly for 1 axis", function()
        local input = "flex flex-row text-center"
        local want = "flex flex-row text-center px-4"
        local got = module.replace_tailwind_padding_classes(input, "x", "px-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for 1 axis", function()
        local input = "text-gray-400 flex flex-row py-20 text-center"
        local want = "text-gray-400 flex flex-row py-4 text-center"
        local got = module.replace_tailwind_padding_classes(input, "y", "py-4")
        assert.equals(want, got)
    end)
    it("removes correctly for 1 axis", function()
        local input = "text-gray-400 flex flex-row px-20 text-center"
        local want = "text-gray-400 flex flex-row text-center"
        local got = module.replace_tailwind_padding_classes(input, "x", "")
        assert.equals(want, got)
    end)
end)
