local module = require("Gambit.lib.classes-manipulator")

local list = {
    { keymap = "f", classes = { "flex" } },
    { keymap = "r", classes = { "flex", "flex-row" } },
    { keymap = "c", classes = { "flex", "flex-col" } },
}

describe("replace_classes_with_list_item()", function()
    it("adds classes correctly", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-500 bg-pink-300"
        local want = "flex flex-row text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex", "flex-row" })
        assert.equals(want, got)
    end)
    it("removes classes correctly", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-500 flex flex-row bg-pink-300"
        local want = "flex text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex" })
        assert.equals(want, got)
    end)

    -- w/ pseudo-classes
    it("adds classes correctly w/ pseudo-classes && empty slate", function()
        PSEUDO_CLASSES = "sm:"
        local input = "text-gray-500 bg-pink-300"
        local want = "sm:flex sm:flex-row text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex", "flex-row" })
        assert.equals(want, got)
    end)
    it("adds classes correctly w/ pseudo-classes && normal value in place, sm:", function()
        PSEUDO_CLASSES = "sm:"
        local input = "flex flex-row text-gray-500 bg-pink-300"
        local want = "sm:flex sm:flex-row flex flex-row text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex", "flex-row" })
        assert.equals(want, got)
    end)
    it("adds classes correctly w/ pseudo-classes && normal value in place, sm:hover:", function()
        PSEUDO_CLASSES = "sm:hover:"
        local input = "flex flex-row text-gray-500 bg-pink-300"
        local want = "sm:hover:flex sm:hover:flex-row flex flex-row text-gray-500 bg-pink-300"
        local got = module.replace_classes_with_list_item(input, list, { "flex", "flex-row" })
        assert.equals(want, got)
    end)
end)

describe("replace_pms_classes", function()
    it("adds correctly for omni axis", function()
        PSEUDO_CLASSES = ""
        local input = "flex flex-row gap-4 text-center"
        local want = "flex flex-row gap-4 text-center p-4"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for omni axis", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row gap-4 p-20 text-center"
        local want = "text-gray-400 flex flex-row gap-4 p-4 text-center"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("removes correctly for omni axis", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row p-20 text-center"
        local want = "text-gray-400 flex flex-row text-center"
        local got = module.replace_pms_classes(input, "p", "", "")
        assert.equals(want, got)
    end)

    it("adds correctly for 1 axis", function()
        PSEUDO_CLASSES = ""
        local input = "flex flex-row text-center"
        local want = "flex flex-row text-center px-4"
        local got = module.replace_pms_classes(input, "p", "x", "px-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for 1 axis", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row py-20 text-center"
        local want = "text-gray-400 flex flex-row py-4 text-center"
        local got = module.replace_pms_classes(input, "p", "y", "py-4")
        assert.equals(want, got)
    end)
    it("removes correctly for 1 axis", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row px-20 text-center"
        local want = "text-gray-400 flex flex-row text-center"
        local got = module.replace_pms_classes(input, "p", "x", "")
        assert.equals(want, got)
    end)

    -- with pseudo-classes
    it("adds correctly for omni axis w/ pseudo-classes && empty slate", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row text-center"
        local want = "flex flex-row text-center hover:p-4"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("adds correctly for omni axis w/ pseudo-classes && normal value in place", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row text-center p-10"
        local want = "flex flex-row text-center p-10 hover:p-4"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for pseudo omni axis", function()
        PSEUDO_CLASSES = "hover:"
        local input = "text-gray-400 flex flex-row hover:p-10 text-center"
        local want = "text-gray-400 flex flex-row hover:p-4 text-center"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)
    it("replaces correctly for omni axis w/ pseudo-classes && normal value in place", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row text-center p-10 hover:p-10"
        local want = "flex flex-row text-center p-10 hover:p-4"
        local got = module.replace_pms_classes(input, "p", "", "p-4")
        assert.equals(want, got)
    end)

    it("adds correctly for 1 axis /w pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row text-center px-4"
        local want = "flex flex-row text-center px-4 hover:px-2"
        local got = module.replace_pms_classes(input, "p", "x", "px-2")
        assert.equals(want, got)
    end)
    it("replaces correctly for 1 axis /w pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row text-center px-4 hover:px-10"
        local want = "flex flex-row text-center px-4 hover:px-2"
        local got = module.replace_pms_classes(input, "p", "x", "px-2")
        assert.equals(want, got)
    end)
end)

describe("remove_pms_classes", function()
    it("removes all space- classes if given no axis argument", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row space-x-20 space-y-4 py-10 text-center"
        local want = "text-gray-400 flex flex-row py-10 text-center"
        local got = module.remove_pms_classes(input, "space-", "all")
        assert.equals(want, got)
    end)
    it("removes chosen space- classes if given axis arguments", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row space-x-20 space-y-10 text-center"
        local want = "text-gray-400 flex flex-row space-x-20 text-center"
        local got = module.remove_pms_classes(input, "space-", "y")
        assert.equals(want, got)
    end)
    it("does nothing if no axis arguments given", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local got = module.remove_pms_classes(input)
        assert.equals(want, got)
    end)

    -- with pseudo-classes
    it("removes all space classes if given no axis argument w/ pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "text-gray-400 flex flex-row space-x-20 hover:space-y-4 py-10 text-center"
        local want = "text-gray-400 flex flex-row space-x-20 py-10 text-center"
        local got = module.remove_pms_classes(input, "space-", "all")
        assert.equals(want, got)
    end)
    it("removes chosen space- classes if given axis arguments w/ pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input =
            "text-gray-400 flex flex-row space-x-20 space-y-10 hover:space-y-20 text-center"
        local want = "text-gray-400 flex flex-row space-x-20 space-y-10 text-center"
        local got = module.remove_pms_classes(input, "space-", "y")
        assert.equals(want, got)
    end)
end)

describe("replace_tailwind_color_classes", function()
    it("adds correctly", function()
        PSEUDO_CLASSES = ""
        local input = "flex flex-row px-20 py-10 text-center"
        local want = "flex flex-row px-20 py-10 text-center text-blue-800"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("replaces correctly", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-blue-800 flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("removes correctly", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "" })
        assert.equals(want, got)
    end)
    it("adds and replaces correctly given both text and bg colors", function()
        PSEUDO_CLASSES = ""
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-blue-800 flex flex-row px-20 py-10 text-center bg-gray-100"
        local got = module.replace_tailwind_color_classes(
            input,
            { text = "text-blue-800", bg = "bg-gray-100" }
        )
        assert.equals(want, got)
    end)

    -- with pseudo-classes
    it("adds correctly w/ pseudo-classes && empty slate", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row px-20 py-10 text-center"
        local want = "flex flex-row px-20 py-10 text-center hover:text-blue-800"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("adds correctly w/ pseudo-classes && normal value", function()
        PSEUDO_CLASSES = "hover:"
        local input = "flex flex-row px-20 py-10 text-center text-gray-400"
        local want = "flex flex-row px-20 py-10 text-center text-gray-400 hover:text-blue-800"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("adds correctly w/ multi-pseudo-classes", function()
        PSEUDO_CLASSES = "sm:hover:"
        local input = "hover:text-gray-400 flex flex-row px-20 py-10 text-center"
        local want =
            "hover:text-gray-400 flex flex-row px-20 py-10 text-center sm:hover:text-blue-800"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)

    it("replaces correctly w/ pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "hover:text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "hover:text-blue-800 flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("replaces correctly w/ pseudo-classes && normal value", function()
        PSEUDO_CLASSES = "hover:"
        local input = "text-red-300 hover:text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "text-red-300 hover:text-blue-800 flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "text-blue-800" })
        assert.equals(want, got)
    end)
    it("replaces correctly w/ multi-pseudo-classes, PSEUDO_CLASSES: hover:", function()
        PSEUDO_CLASSES = "hover:"
        local input =
            "hover:text-gray-400 flex flex-row px-20 py-10 text-center sm:hover:text-blue-800"
        local want =
            "hover:text-yellow-200 flex flex-row px-20 py-10 text-center sm:hover:text-blue-800"
        local got = module.replace_tailwind_color_classes(input, { text = "text-yellow-200" })
        assert.equals(want, got)
    end)
    it("replaces correctly w/ multi-pseudo-classes, PSEUDO_CLASSES: sm:hover:", function()
        PSEUDO_CLASSES = "sm:hover:"
        local input =
            "hover:text-gray-400 flex flex-row px-20 py-10 text-center sm:hover:text-blue-800"
        local want =
            "hover:text-gray-400 flex flex-row px-20 py-10 text-center sm:hover:text-yellow-200"
        local got = module.replace_tailwind_color_classes(input, { text = "text-yellow-200" })
        assert.equals(want, got)
    end)

    it("removes correctly w/ pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "hover:text-gray-400 flex flex-row px-20 py-10 text-center"
        local want = "flex flex-row px-20 py-10 text-center"
        local got = module.replace_tailwind_color_classes(input, { text = "" })
        assert.equals(want, got)
    end)

    it("adds correctly given both text and bg colors w/ pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "text-gray-400 flex flex-row px-20 py-10 text-center"
        local want =
            "text-gray-400 flex flex-row px-20 py-10 text-center hover:text-green-800 hover:bg-white"
        local got = module.replace_tailwind_color_classes(
            input,
            { text = "text-green-800", bg = "bg-white" }
        )
        assert.equals(want, got)
    end)
    it("replaces correctly given both text and bg colors w/ pseudo-classes", function()
        PSEUDO_CLASSES = "hover:"
        local input = "text-gray-400 hover:text-red-300 flex flex-row px-20 py-10 text-center"
        local want =
            "text-gray-400 hover:text-green-800 flex flex-row px-20 py-10 text-center hover:bg-white"
        local got = module.replace_tailwind_color_classes(
            input,
            { text = "text-green-800", bg = "bg-white" }
        )
        assert.equals(want, got)
    end)
end)

describe("pseudo_splitter pattern_check", function()
    it("works for 1 pseudo_prefixes", function()
        local pattern = require("Gambit.lua_patterns").pseudo_splitter
        local str = "sm:text-blue-400"

        local pseudo_prefix, class = string.match(str, pattern)
        assert.equals("sm:", pseudo_prefix)
        assert.equals("text-blue-400", class)
    end)
    it("works for 2 pseudo_prefixes", function()
        local pattern = require("Gambit.lua_patterns").pseudo_splitter
        local str = "sm:hover:text-blue-400"

        local pseudo_prefix, class = string.match(str, pattern)
        assert.equals("sm:hover:", pseudo_prefix)
        assert.equals("text-blue-400", class)
    end)
    it("works for 5 pseudo_prefixes", function()
        local pattern = require("Gambit.lua_patterns").pseudo_splitter
        local str = "sm:dark:hover:first-letter:active:text-blue-400"

        local pseudo_prefix, class = string.match(str, pattern)
        assert.equals("sm:dark:hover:first-letter:active:", pseudo_prefix)
        assert.equals("text-blue-400", class)
    end)
end)
