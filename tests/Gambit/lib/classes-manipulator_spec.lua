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

describe("replace_pms_classes", function()
    it("adds correctly for omni axis", function()
        local input = "flex flex-row text-center"
        local want = "flex flex-row text-center p-4"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for omni axis", function()
        local input = "text-gray-400 flex flex-row p-20 text-center"
        local want = "text-gray-400 flex flex-row p-4 text-center"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("removes correctly for omni axis", function()
        local input = "text-gray-400 flex flex-row p-20 text-center"
        local want = "text-gray-400 flex flex-row text-center"
        local got = module.replace_pms_classes(input, "p", "", "")
        assert.equals(want, got)
    end)

    it("adds correctly for 1 axis", function()
        local input = "flex flex-row text-center"
        local want = "flex flex-row text-center px-4"
        local got = module.replace_pms_classes(input, "p", "x", "px-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for 1 axis", function()
        local input = "text-gray-400 flex flex-row py-20 text-center"
        local want = "text-gray-400 flex flex-row py-4 text-center"
        local got = module.replace_pms_classes(input, "p", "y", "py-4")
        assert.equals(want, got)
    end)
    it("removes correctly for 1 axis", function()
        local input = "text-gray-400 flex flex-row px-20 text-center"
        local want = "text-gray-400 flex flex-row text-center"
        local got = module.replace_pms_classes(input, "p", "x", "")
        assert.equals(want, got)
    end)
end)

describe("remove_pms_classes", function()
    it("removes all padding classes if given no axis argument", function()
        local input = "text-gray-400 flex flex-row space-x-20 space-y-4 py-10 text-center"
        local want = "text-gray-400 flex flex-row py-10 text-center"
        local got = module.remove_pms_classes(input, "space-", "all")
        assert.equals(want, got)
    end)
    it("removes chosen padding classes if given axis arguments", function()
        local input = "text-gray-400 flex flex-row space-x-20 space-y-10 text-center"
        local want = "text-gray-400 flex flex-row space-x-20 text-center"
        local got = module.remove_pms_classes(input, "space-", "y")
        assert.equals(want, got)
    end)
    it("does nothing if no axis arguments given", function()
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local got = module.remove_pms_classes(input)
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
