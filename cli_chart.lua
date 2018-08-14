-- luacheck: max line length 80
--------------------------------------------------------------------------------

-- cli_table.lua
-- Copyright (c) 2018 RussDragon <russdragon9000@gmail.com>

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the 'Software'), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

--------------------------------------------------------------------------------

local bold_theme =
{
  ulCorner = "┏";
  llCorner = "┗";
  urCorner = "┓";
  lrCorner = "┛";
  vertical = "┃";
  horizontal = "━";
  dhorizontal = "┳";
  uhorizontal = "┻";
  crosschar = "╋";
  lhvchar = "┫";
  rhvchar = "┣";
}

--------------------------------------------------------------------------------

-- TODO:
-- Theme support
-- Multiline support
-- Add one 'big' multirow cell

--------------------------------------------------------------------------------

-- Space indentation between separators
local indent = 2

--TODO: add error validations
local make_cli_chart
do
  local center_with_spaces = function(str, len)
    if not str or not len then
      error('center_with_spaces: str and len must be passed')
    end

    local div = len - #str
    local res

    if div % 2 == 0 then
      local spaces = string.rep(' ', div / 2)
      res = spaces .. str .. spaces
    else
      local spaces = string.rep(' ', div / 2)
      res = spaces .. str .. spaces .. ' '
    end

    return res
  end

  local render_line = function(char, len)
    if not char or not len then
      error('render_line: char and len must be passed')
    end

    local str = char:rep(len)

    return str
  end

  local render_headers = function(chart, theme)
    if not chart or not theme then
      error('render_headers: chart and theme must be passed')
    end

    local headers = chart.headers
    local sizes = chart.config.sizes

    if #headers == 0 then
      local topline = theme.ulCorner
      for i = 1, chart.config.width do
        local line = render_line(theme.horizontal, sizes[i])

        local tinterchar = theme.dhorizontal
        if i == chart.config.width then tinterchar = theme.urCorner end
        topline = topline .. line .. tinterchar
      end

      return topline .. '\n'
    end

    local topline = theme.ulCorner
    local midline = theme.vertical
    local botline = theme.rhvchar

    for i = 1, chart.config.width do
      local line = render_line(theme.horizontal, sizes[i])

      midline = midline .. center_with_spaces(headers[i], sizes[i]) ..
                theme.vertical

      local tinterchar = theme.dhorizontal
      local binterchar = theme.crosschar
      if i == chart.config.width then
        tinterchar = theme.urCorner
        binterchar = theme.lhvchar
      end

      topline = topline .. line .. tinterchar
      botline = botline .. line .. binterchar
    end

    return topline .. '\n' ..
           midline .. '\n' ..
           botline .. '\n'
  end

  local render_row = function(row, sizes, vchar, lcchar, rcchar, hchar, ichar)
    if not row or not sizes or not vchar or not lcchar or not rcchar or
       not hchar or not ichar
    then
      error(
        'render_row: row, sizes, vchar, lcchar, rcchar, hchar, ichar' ..
        ' must be passed'
      )
    end

    local midline = vchar
    local botline = lcchar
    for i = 1, #row do
      local v = row[i]
      if #v < sizes[i] then
        v = center_with_spaces(v, sizes[i])
      end

      midline = midline .. v .. vchar

      local endchar = ichar
      if i == #row then
        endchar = rcchar
      end

      botline = botline .. render_line(hchar, sizes[i]) .. endchar
    end


    return midline .. '\n' ..
           botline .. '\n'
  end

  local render_rows = function(chart, theme)
    if not chart or not theme then
      error('render_rows: chart and theme must be passed')
    end

    local rows = chart.rows
    local contentline = ''

    if #rows == 0 then
      rows[#rows + 1] = { }
      for i = 1, chart.config.width do
        rows[#rows][i] = ''
      end
    end

    for i = 1, #rows do
      if i == #rows then
        contentline = contentline .. render_row(
            rows[i],
            chart.config.sizes,
            theme.vertical,
            theme.llCorner,
            theme.lrCorner,
            theme.horizontal,
            theme.uhorizontal
          )
      else
        contentline = contentline .. render_row(
            rows[i],
            chart.config.sizes,
            theme.vertical,
            theme.rhvchar,
            theme.lhvchar,
            theme.horizontal,
            theme.crosschar
          )
      end
    end

    return contentline
  end

  local render = function(self)
    return render_headers(self._chart, self._theme) ..
           render_rows(self._chart, self._theme)
  end

  local insert = function(self, ...)
    local args = { ... }

    local config = self._chart.config
    local rows = self._chart.rows

    if config.width == 0 then config.width = #args end

    rows[#rows + 1] = { }
    for i = 1, config.width do
      local v = tostring(args[i])

      if v == 'nil' then v = '' end

      if not config.sizes[i] or #v + indent > config.sizes[i] then
        config.sizes[i] = #v + indent
      end

      rows[#rows][i] = v
    end
  end

  local replace = function(self, id, ...)
    id = tonumber(id)
    if not id or not self._chart.rows[id] then
      error('replace: correct id must be specified')
    end

    local args = { ... }
    local config = self._chart.config
    local rows = self._chart.rows

    rows[id] = { }
    for i = 1, config.width do
      local v = tostring(args[i])

      if v == 'nil' then v = '' end

      if not config.sizes[i] or #v + indent > config.sizes[i] then
        config.sizes[i] = #v + indent
      end

      rows[id][i] = v
    end
  end

  -- Slow on big charts
  local remove = function(self, id)
    id = tonumber(id)
    if not id or not self._chart.rows[id] then
      error('remove: correct id must be specified')
    end

    local rows = self._chart.rows

    for i = id, #rows do
      rows[i] = rows[i + 1]
    end
  end

  make_cli_chart = function(...)
    local args = { ... }

    local chart = { }
    chart.headers = { }
    chart.rows = { }

    chart.config = { }
    chart.config.sizes = { }
    chart.config.width = #args

    for i = 1, chart.config.width do
      local v = tostring(args[i])
      chart.config.sizes[i] = #v + indent
      chart.headers[i] = v
    end

    return
    {
      insert = insert;
      replace = replace;
      remove = remove;
      render = render;

      _chart = chart;
      _theme = bold_theme;
    }
  end
end

--------------------------------------------------------------------------------

return make_cli_chart
