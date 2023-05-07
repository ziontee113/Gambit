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
