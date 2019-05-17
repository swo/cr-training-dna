-- Put an OpenBiome logo in the bottom-left of any slide that doesn't already
-- have a background image
function Header(header)
    if header.level == 1 and header.attributes["data-background-image"] == nil then
        header.attributes["data-background-image"] = "img/openbiome-logo.png"
        header.attributes["data-background-position"] = "5% 95%"
        header.attributes["data-background-size"] = "15%"
    end

    return header
end
