-- Replace Para's whose first word is "footer:" with a footer Div, so
-- `footer: foo bar` -> `<div class="footer">foo bar</div>`

function Para(para)
    if para.c[1].c == "footer:" then
        table.remove(para.c, 1)
        if para.c[1].t == "Space" then table.remove(para.c, 1) end

        attrs = pandoc.Attr("", { "footer" }, {})
        return pandoc.Div(pandoc.Plain(para.c), attrs)
    else
        return para
    end
end
