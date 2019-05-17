-- This filter makes it easier to make tables. The start of a table is marked
-- by a line starting with `table:`, followed by an optional caption. The
-- following lines are the rows, with cells separated by `||`.

-- table: My caption
-- row1 cell1 || row1 cell2
-- row2 cell1 || row2 cell2


-- Convenience function for examining tables
local inspect = require "inspect"

local remove_all_metatables = function(item, path)
  if path[#path] ~= inspect.METATABLE then return item end
end

function my_inspect (x)
    print(inspect(x, { process = remove_all_metatables }))
end

-- Apply a function to each value
function map(table, f)
    result = {}
    for key, value in pairs(table) do
        result[key] = f(value)
    end
    return result
end

-- Split a list into a list of lists
-- e.g., if predictate is `function (x) return x == 0 end`, then
-- { 0, 1, 2, 0, 3, 4 } --> { {}, {1, 2}, {3, 4} }
function split_by (list, predicate)
    local list_of_lists = { {} }
    for i, element in ipairs(list) do
        if predicate(element) then
            table.insert(list_of_lists, { })
        else
            table.insert(list_of_lists[#list_of_lists], element)
        end
    end
    return list_of_lists
end

-- Remove leading or trailing Space's from a list
function trim (x)
    if x[1] and x[1].t == "Space" then table.remove(x, 1) end
    if x[#x] and x[#x].t == "Space" then table.remove(x, #x) end
    return x
end

function parse_table (content)
    assert(content[1].t == "Str" and content[1].text == "table:")

    local lines = split_by(content, function(x) return type(x) == "table" and x.t and x.t == "SoftBreak" end)

    -- caption is the words on the first line, except the first one
    -- (list of Inlines)
    local caption = lines[1]
    assert(caption[1].c == "table:")
    table.remove(caption, 1)
    caption = trim(caption) -- remove spaces

    -- rows is everything that's left
    -- (a list of rows, each row a list of cells, each cell a list of Blocks)
    table.remove(lines, 1)
    local rows = {} -- a list of rows
    for _, line in pairs(lines) do
        -- now, each cell is a list of Inlines (e.g., Str)
        local row = split_by(line, function(x) return x.t == "Str" and x.c == "||" end)

        -- make each cell a length-1 list of Blocks, i.e., Plain(list of inlines)
        -- so that each cell is a list of Blocks
        row = map(row, function(x) return { pandoc.Plain(trim(x)) } end)

        -- a list of cells is a row
        table.insert(rows, row)
    end

    -- check that all rows have the same number of columns
    local n_columns = #rows[1]
    for _, row in pairs(rows) do
        assert(#row == n_columns)
    end

    local aligns = {} -- a list of pandoc.AlignDefault, pandoc.AlignLeft, etc.
    for i = 1, n_columns do
        table.insert(aligns, pandoc.AlignDefault)
    end

    local widths = {} -- empty list, or list of numerics
    local headers = {} -- a list of cells, each cell a list of Blocks

    return pandoc.Table(caption, aligns, widths, headers, rows)
end

function Para (para)
    if para.c[1] and para.c[1].t == "Str" and para.c[1].text == "table:" then
        return parse_table(para.c)
    else
        return para
    end
end
