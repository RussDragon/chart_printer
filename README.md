# Requirements
- Lua 5.1

# Installation
Clone this repo to your computer and add cli_table.lua file to your project

# Usage
```
local chart_builder = require 'cli_table'

local chart = chart_builder('First column', 'second', 'third')
chart:insert('valueone', '111', 'yoyo')
chart:replace(1, 'newone', '222', 'asd')

print(chart:render())

chart:remove(1)

print(chart:render())
```

===============================================================================

Copyright (c) 2018, RussDragon <russdragon9000@gmail.com>
See file COPYRIGHT for the license.
