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

    pseudo_splitter = "^(.-:)(.*)$",
}

return M
