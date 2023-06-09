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

    --------------------------------------------

    text_color = {
        "^text%-%a+%-%d+",
        "^text%-black",
        "^text%-white",
        "text%-%[rgb%([%d%s,]+%)]",
        "text%-%[rgba%([%d%s,%.]+%)]",
        "text%-%[hsl%([%d%s%%,]+%)]",
        "text%-%[hsla%([%d%s%%,%.]+%)]",
        "text%-%[#[%da-fA-F]+]",
    },
    background_color = {
        "^bg%-%a+%-%d+",
        "^bg%-black",
        "^bg%-white",
        "bg%-%[rgb%([%d%s,]+%)]",
        "bg%-%[rgba%([%d%s,%.]+%)]",
        "bg%-%[hsl%([%d%s%%,]+%)]",
        "bg%-%[hsla%([%d%s%%,%.]+%)]",
        "bg%-%[#[%da-fA-F]+]",
    },

    --stylua: ignore
    css_colors = {
        "black", "silver", "gray", "white", "maroon", "red", "purple", "fuchsia",
        "green", "lime", "olive", "yellow", "navy",
        "blue", "teal", "aqua", "aliceblue", "antiquewhite",
        "aqua", "aquamarine", "azure", "beige", "bisque",
        "black", "blanchedalmond", "blue", "blueviolet", "brown", "burlywood",
        "cadetblue", "chartreuse", "chocolate", "coral", "cornflowerblue",
        "cornsilk", "crimson", "cyan", "darkblue", "darkcyan", "darkgoldenrod",
        "darkgray", "darkgreen", "darkgrey", "darkkhaki", "darkmagenta",
        "darkolivegreen", "darkorange", "darkorchid", "darkred", "darksalmon",
        "darkseagreen", "darkslateblue", "darkslategray", "darkslategrey",
        "darkturquoise", "darkviolet", "deeppink", "deepskyblue", "dimgray",
        "dimgrey", "dodgerblue", "firebrick", "floralwhite", "forestgreen",
        "fuchsia", "gainsboro", "ghostwhite", "gold", "goldenrod", "gray",
        "green", "greenyellow", "grey", "honeydew", "hotpink", "indianred",
        "indigo", "ivory", "khaki", "lavender", "lavenderblush", "lawngreen",
        "lemonchiffon", "lightblue", "lightcoral", "lightcyan", "lightgoldenrodyellow",
        "lightgray", "lightgreen", "lightgrey", "lightpink", "lightsalmon",
        "lightseagreen", "lightskyblue", "lightslategray", "lightslategrey",
        "lightsteelblue", "lightyellow", "lime", "limegreen", "linen",
        "magenta", "maroon", "mediumaquamarine", "mediumblue", "mediumorchid",
        "mediumpurple", "mediumseagreen", "mediumslateblue", "mediumspringgreen",
        "mediumturquoise", "mediumvioletred", "midnightblue", "mintcream",
        "mistyrose", "moccasin", "navajowhite", "navy", "oldlace", "olive",
        "olivedrab", "orange", "orangered", "orchid", "palegoldenrod",
        "palegreen", "paleturquoise", "palevioletred", "papayawhip", "peachpuff",
        "peru", "pink", "plum", "powderblue", "purple", "red", "rosybrown",
        "royalblue", "saddlebrown", "salmon", "sandybrown", "seagreen", "seashell",
        "sienna", "silver", "skyblue", "slateblue", "slategray", "slategrey",
        "snow", "springgreen", "steelblue", "tan", "teal",
        "thistle", "tomato", "turquoise", "violet", "wheat", "white",
        "whitesmoke", "yellow", "yellowgreen",
    },

    ----------------------------------

    pms = {
        p = {
            [""] = { "^p%-%d+$", "^p%-%[%d+%a+]$" },
            ["x"] = { "^px%-%d+$", "^px%-%[%d+%a+]$" },
            ["y"] = { "^py%-%d+$", "^py%-%[%d+%a+]$" },
            ["t"] = { "^pt%-%d+$", "^pt%-%[%d+%a+]$" },
            ["b"] = { "^pb%-%d+$", "^pb%-%[%d+%a+]$" },
            ["l"] = { "^pl%-%d+$", "^pl%-%[%d+%a+]$" },
            ["r"] = { "^pr%-%d+$", "^pr%-%[%d+%a+]$" },
            ["all"] = { "^p[xytblr]?%-%d+$", "^p[xytblr]?%-%[%d+%a+]$" },
        },
        m = {
            [""] = { "^m%-%d+$", "^m%-%[%d+%a+]$" },
            ["x"] = { "^mx%-%d+$", "^mx%-%[%d+%a+]$" },
            ["y"] = { "^my%-%d+$", "^my%-%[%d+%a+]$" },
            ["t"] = { "^mt%-%d+$", "^mt%-%[%d+%a+]$" },
            ["b"] = { "^mb%-%d+$", "^mb%-%[%d+%a+]$" },
            ["l"] = { "^ml%-%d+$", "^ml%-%[%d+%a+]$" },
            ["r"] = { "^mr%-%d+$", "^mr%-%[%d+%a+]$" },
            ["all"] = { "^m[xytblr]?%-%d+$", "^m[xytblr]?%-%[%d+%a+]$" },
        },
        ["space-"] = {
            ["x"] = { "^space%-x%-%d+$", "^spacex%-%[%d+%a+]$" },
            ["y"] = { "^space%-y%-%d+$", "^spacey%-%[%d+%a+]$" },
            ["all"] = { "^space%-[xy]?%-%d+$", "^space[xytblr]?%-%[%d+%a+]$" },
        },
    },

    ----------------------------------

    pseudo_splitter = "^(.-:)([^:]+)$",
    pseudo_element_content = "^content%-%['.*']$",
}

return M
