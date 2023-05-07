local M = {
    font_weight = {
        "font-thin",
        "font-extralight",
        "font-light",
        "font-normal",
        "font-medium",
        "font-semibold",
        "font-bold",
        "font-extrabold",
        "font-black",
    },
    text_decoration = {
        "underline",
        "overline",
        "line-through",
        "no-underline",
    },
    font_style = {
        "italic",
        "not-italic",
    },
    font_size = {
        "text%-xs",
        "text%-sm",
        "text%-base",
        "text%-lg",
        "text%-xl",
        "text%-2xl",
        "text%-3xl",
        "text%-4xl",
        "text%-5xl",
        "text%-6xl",
        "text%-7xl",
        "text%-8xl",
        "text%-9xl",
    },
    text_color = {
        "^text%-%a+%-%d+",
        "^text%-black",
        "^text%-white",
    },
    background_color = {
        "^bg%-%a+%-%d+",
        "^bg%-black",
        "^bg%-white",
    },

    ----------------------------------

    pms_patterns = {
        p = {
            [""] = "^p%-%d+$",
            ["x"] = "^px%-%d+$",
            ["y"] = "^py%-%d+$",
            ["t"] = "^pt%-%d+$",
            ["b"] = "^pb%-%d+$",
            ["l"] = "^pl%-%d+$",
            ["r"] = "^pr%-%d+$",
            ["all"] = "^p[xytblr]?%-%d+$",
        },
        m = {
            [""] = "^m%-%d+$",
            ["x"] = "^mx%-%d+$",
            ["y"] = "^my%-%d+$",
            ["t"] = "^mt%-%d+$",
            ["b"] = "^mb%-%d+$",
            ["l"] = "^ml%-%d+$",
            ["r"] = "^mr%-%d+$",
            ["all"] = "^m[xytblr]?%-%d+$",
        },
        ["space-"] = {
            ["x"] = "^space%-x%-%d+$",
            ["y"] = "^space%-y%-%d+$",
            ["all"] = "^space%-[xy]?%-%d+$",
        },
    },

    ----------------------------------

    pseudo_splitter = "^(.-:)([^:]+)$",
}

return M
