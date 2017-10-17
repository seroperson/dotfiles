-- {{{ required libraries

local gears = require("gears")
local awful = require("awful")
local rules = require("awful.rules")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
require("asyncshell")
require("awful.autofocus")

-- }}}

-- {{{ variable definitions

modkey = "Mod4"
altkey = "Mod1"
theme = "rainbow"
terminal = "urxvtc"
brightness_path = "/sys/class/backlight/intel_backlight/brightness"

-- }}}

-- {{{ functions

-- starts application if it isn't started yet (thanks to copycat-killer)
local function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- updates an image representation of the current layout in a imagebox widget
local function update_layoutbox(layout, screenNumber)
  local screen = screenNumber or 1
  local path = beautiful["layout_" .. awful.layout.getname(awful.layout.get(screen))] or ""
  layout:set_image(path)
end

-- minimize the given client
local function minimize(c)
  c.minimized = true
end

-- maximize the given client
local function maximize(c)
  c.minimized = false
  if not c:isvisible() then
    awful.tag.viewonly(c:tags()[1])
  end
  client.focus = c
  c:raise()
end

-- returns the next screen index
local function next_screen(d)
  local next_screen = mouse.screen + d
  local real_next_screen = math.fmod(next_screen, screen.count())
  if real_next_screen == 0 then
    if not next_screen == 0 then
      real_next_screen = 1
    else
      real_next_screen = screen.count()
    end
  end
  return real_next_screen
end

-- returns the function that moves client to the screen + d
local function move_client_by(d)
  return function (c)
    awful.client.movetoscreen(c, next_screen(d))
  end
end

-- todo: should be moved out
run_once("urxvtd --quiet --opendisplay --fork")

-- }}}

-- {{{ ui

-- {{{ naughty and theme configuration

beautiful.init(awful.util.getdir("config") .. "/themes/" .. theme .. "/theme.lua")
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

local layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile
}

naughty.config.defaults.timeout = 60
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.icon_size = 32

-- }}}

-- {{{ tags

-- we're using images instead of text for tags, so there is " " strings
local tags = {
  names = { "  ", "  ", "  ", "  ", "  ", "  " },
  layouts = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layouts)
end

-- }}}

-- {{{ widgets

local volume_icon = wibox.widget.imagebox(theme.icon_volume)
local volume_line = wibox.widget.textbox('')

-- Textclock
local clock_icon = wibox.widget.imagebox(theme.icon_clock)
local clock_line = awful.widget.textclock('%H:%M', 60)

-- Battery
local battery_icon = wibox.widget.imagebox(theme.icon_battery3)
local battery_line = wibox.widget.textbox('')
local battery_timer = timer({ timeout = 60 })
battery_timer:connect_signal("timeout", function()
  -- todo: so dirty
  asyncshell.request(os.getenv('HOME') .. '/Development/Workspace/VimProjects/Scripts/battery.sh', function(f)
    local value = tonumber(f:read("*l"))
    local icon = ""
    if value > 80 then
      icon = theme.icon_battery3
    else
      if value > 50 then
        icon = theme.icon_battery2
      else
        if value > 20 then
          icon = theme.icon_battery1
        else
          if value > 5 then
            icon = theme.icon_battery0
          end
        end
      end
    end
    battery_icon:set_image(icon)
    battery_line:set_text(value .. "%")
  end)
end)
battery_timer:start()
battery_timer:emit_signal("timeout")

-- just separator (spacing)
local spr_med = wibox.widget.textbox('  ')

-- }}}

-- create a wibox for each screen and add it
local topwibox = { }
local bottomwibox = { }
local layoutbox = { }
local taglist = { }
local tasklist = { }
tasklist.buttons = awful.util.table.join(awful.button({ }, 1, function (c)
  if c == client.focus then
    minimize(c)
  else
    maximize(c)
  end
end))

-- {{{ applying ui for each available screen

for s = 1, screen.count() do
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)
  tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons)
  layoutbox[s] = wibox.widget.imagebox(beautiful["layout_" .. awful.layout.getname(awful.layout.get(s))])
  local callback = function () update_layoutbox(layoutbox[s], s) end
  awful.tag.attached_connect_signal(s, "property::selected", callback)
  awful.tag.attached_connect_signal(s, "property::layout", callback)

  -- {{{ setting up layout_top

  local layout_top = wibox.layout.align.horizontal()

  -- {{{ setting up left_layout_top

  local layoutbox_margin = wibox.layout.margin()
  layoutbox_margin:set_left(7)
  layoutbox_margin:set_right(5)
  layoutbox_margin:set_widget(layoutbox[s])

  local left_layout_top = wibox.layout.fixed.horizontal()
  left_layout_top:add(taglist[s])
  left_layout_top:add(layoutbox_margin)

  layout_top:set_left(left_layout_top)

  -- }}}

  -- {{{ setting up middle_layout_top

  local tasklist_margin = wibox.layout.margin()
  tasklist_margin:set_bottom(3)
  tasklist_margin:set_widget(tasklist[s])

  layout_top:set_middle(tasklist_margin)

  -- }}}

  -- {{{ setting up right_layout_top

  local right_layout_top = wibox.layout.fixed.horizontal()

  layout_top:set_right(right_layout_top)

  -- }}}

  topwibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })
  topwibox[s]:set_widget(layout_top)
  topwibox[s]:set_bg(theme.top_bg)

  -- }}}

  -- bottom layout is available just for main screen
  if s == 1 then

    -- {{{ setting up layout_bottom

    local layout_bottom = wibox.layout.align.horizontal()

    -- {{{ setting up right_layout_bottom

    local right_layout_bottom = wibox.layout.fixed.horizontal()
    right_layout_bottom:add(battery_icon)
    right_layout_bottom:add(battery_line)
    right_layout_bottom:add(spr_med)
    right_layout_bottom:add(clock_icon)
    right_layout_bottom:add(clock_line)
    right_layout_bottom:add(spr_med)

    layout_bottom:set_right(right_layout_bottom)

    -- }}}

    bottomwibox[s] = awful.wibox({ position = "bottom", screen = s, height = 22 })
    bottomwibox[s]:set_widget(layout_bottom)
    bottomwibox[s]:set_bg(theme.bottom_bg)

    -- }}}

  end
end

-- }}}

-- }}}

-- {{{ key bindings

local muted = false
local globalkeys = awful.util.table.join(
  awful.key({ modkey }, "r", function() run_once("rofi -X -show run") end),
  -- screenshot
  awful.key({ modkey }, "Print", function ()
    local screen_tmp = "screenshot.png"
    local screen_make = "import " .. screen_tmp
    local screen_path = "/home/seroperson/Pictures/Screenshots/"
    local screen_name = "`date | sha256sum | base64 | head -c10; echo`"
    os.execute(screen_make.." && mv "..screen_tmp.." " ..screen_path.."/"..screen_name..".png")
  end),
  -- disable screen
  awful.key({ modkey }, "F12", function () os.execute("sleep 2 && xset dpms force off") end),
  -- change volume level
  awful.key({ }, "F8", function () os.execute("amixer -c 0 set Master 5dB-") end),
  awful.key({ }, "F9", function () os.execute("amixer -c 0 set Master 5dB+") end),
  awful.key({ }, "F7", function ()
    if muted then
      os.execute("amixer -c 0 set Master unmute")
      muted = false
    else
      os.execute("amixer -c 0 set Master mute")
      muted = true
    end
  end),
  -- run terminal
  awful.key({ modkey }, "Return", function () os.execute(terminal) end),
  -- change brightness
  -- todo: move such settings to 'per-machine-rc.lua' or sth like that
  awful.key({ altkey }, "F4", function () os.execute("echo $((`cat "..brightness_path.."`-10)) | sudo tee "..brightness_path) end),
  awful.key({ altkey }, "F5", function () os.execute("echo $((`cat "..brightness_path.."`+10)) | sudo tee "..brightness_path) end),

  -- focusing windows
  awful.key({ modkey }, "k", function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, "j", function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),

  -- change window ordering
  awful.key({ modkey, "Shift" }, ";", function () awful.client.swap.byidx(-1) end),
  awful.key({ modkey, "Shift" }, "g", function () awful.client.swap.byidx(1) end),

  -- move functions (mod + shift + control + jkhl)
  awful.key({ modkey, "Shift", "Control" }, "j", function () awful.client.moveresize(0, 20, 0, 0) end),
  awful.key({ modkey, "Shift", "Control" }, "k", function () awful.client.moveresize(0, -20, 0, 0) end),
  awful.key({ modkey, "Shift", "Control" }, "h", function () awful.client.moveresize(-20, 0, 0, 0) end),
  awful.key({ modkey, "Shift", "Control" }, "l", function () awful.client.moveresize(20, 0, 0, 0) end),

  -- resize by xy axis
  awful.key({ modkey, "Shift", altkey }, ";", function () awful.client.moveresize(0, 0, 20, 20) end),
  awful.key({ modkey, "Shift", altkey }, "g", function () awful.client.moveresize(0, 0, -20, -20) end),

  -- resize functions (mod + shift + altkey + jkhl)
  awful.key({ modkey, "Shift", altkey }, "j", function () awful.client.moveresize(0, 0, 0, 20) end),
  awful.key({ modkey, "Shift", altkey }, "k", function () awful.client.moveresize(0, 0, 0, -20) end),
  awful.key({ modkey, "Shift", altkey }, "h", function () awful.client.moveresize(0, 0, -20, 0) end),
  awful.key({ modkey, "Shift", altkey }, "l", function () awful.client.moveresize(0, 0, 20, 0) end),

  -- layout manipulation
  awful.key({ modkey, altkey }, "space", function () awful.layout.inc(layouts, 1) end),

  awful.key({ modkey, "Shift" }, "j", function ()
    awful.screen.focus(next_screen(-1))
  end),
  awful.key({ modkey, "Shift" }, "k", function ()
    awful.screen.focus(next_screen(1))
  end),

  awful.key({ "Control" }, "F12", awesome.restart))

-- bind all key numbers to tags.
local F = { "F1", "F2", "F3", "F4", "F5", "F6" }
for i = 1, 6 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, F[i], function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewonly(tag)
      end
      awful.client.focus.byidx(0)
      if client.focus then
        client.focus:raise()
      end
    end),
    awful.key({ modkey, "Shift" }, F[i], function ()
      local tag = awful.tag.gettags(client.focus.screen)[i]
      if client.focus and tag then
        awful.client.movetotag(tag)
      end
    end))
end

-- apply keys
root.keys(globalkeys)

-- }}}

-- {{{ rules

-- tip: use xprop to discover the window class
rules.rules = {
  {
    -- all clients will match this rule.
    rule = { },
    properties = { border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    keys = awful.util.table.join(
      -- mod + shift + c - kill focused application
      awful.key({ modkey, "Shift" }, "c", function (c) c:kill() end),
      -- mod + f - fullscreen focused application
      awful.key({ modkey, }, "f", function (c) c.fullscreen = not c.fullscreen end),
      -- mod + t - move focused application on top
      awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end),
      awful.key({ modkey, "Shift" }, "n", function (c)
        local screen = mouse.screen
        local tag = awful.tag.selected(screen)
        local tag_clients = tag:clients()
        for key, client in pairs(tag_clients) do
          unminimize(client)
        end
      end),
      awful.key({ modkey, }, "n", function (c)
        if c == client.focus then
          minimize(c)
        end
      end),
      awful.key({ modkey, }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical = not c.maximized_vertical
      end),
      awful.key({ modkey, altkey }, "j", move_client_by(-1)),
      awful.key({ modkey, altkey }, "k", move_client_by(1))),
    buttons = awful.util.table.join(
      awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
      awful.button({ modkey }, 1, awful.mouse.client.move),
      awful.button({ modkey }, 2, awful.mouse.client.resize)),
    callback = function(c) c.size_hints_honor = false end }
  },
  {
    rule = { class = "mpv" },
    properties = { callback = function(c) c.size_hints_honor = true end }
  },
}

-- }}}

-- {{{ signals

client.connect_signal("manage", function (c, startup)
  if not startup and not c.size_hints.user_position
    and not c.size_hints.program_position then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
  end
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
awesome.connect_signal("debug::error", function (err) naughty.notify({ text = err, title = "Error" }) end)

-- }}}
