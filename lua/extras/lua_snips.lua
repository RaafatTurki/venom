local ls = require 'luasnip'

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

return {
  all = {
    s("vimodeline", { t {"vim: commentstring=#%s"} }),
    s("shebang", { t {"#!/usr/bin/bash"} }),

    s("trig", c(1, {
      t("Ugh boring, a text node"),
      i(nil, "At least I can edit something now..."),
      f(function(args) return "Still only counts as text!!" end, {})
    }))
  },
  html = {
    s("html5", {
      t {
        "<html lang=\"en\">",
        "\t<head>",
        "\t\t<title>Web Page</title>",
        "\t\t<meta charset=\"UTF-8\"/>",
        "\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>",
        "\t\t<link href=\"style.css\" rel=\"stylesheet\"/>",
        "\t</head>",
        "\t<body>",
        "\t\t<h1>hi friend!</h1>",
        "\t\t"}, i(0), t {"",
        "\t</body>",
        "</html>"
      },
    }),
  },
}
