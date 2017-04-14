theme = {}

theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/rainbow/"
theme.wallpaper = theme.dir .. "/wall.png"

theme.font = "Ubuntu Bold 8"
theme.bg_systray = "#00000000"
theme.bg_normal = "#0000000"
theme.fg_normal = "#FFFFFF"
theme.border_width = 1
theme.border_focus = "#647a9c"
theme.border_normal = "#222222"

theme.taglist_bg_empty = "png:" .. theme.dir .. "/icons/empty.png"
theme.taglist_bg_occupied = "png:" .. theme.dir .. "/icons/occupied.png"
theme.taglist_bg_focus = "png:" .. theme.dir .. "/icons/focus.png"

theme.tasklist_disable_icon = false
theme.tasklist_font = "Ubuntu Condensed Bold 8"
theme.tasklist_bg_normal = "#00000000"
theme.tasklist_bg_focus = "#00000000"
theme.tasklist_bg_urgent = "#00551111"
theme.tasklist_fg_focus = "#FFFFFF"
theme.tasklist_fg_urgent = "#EEEEEE"
theme.tasklist_fg_normal = "#888888"
theme.tasklist_sticky = "[S] "
theme.tasklist_ontop = "[T] "
theme.tasklist_floating = "[F] "
theme.tasklist_maximized_horizontal = "[M] "
theme.tasklist_maximized_vertical = ""

theme.menu_height = 16
theme.menu_fg_normal = "#FFFFFF"
theme.menu_bg_normal = "#1C1C1C"
theme.menu_bg_pressed = "#1C1C1C"
theme.menu_bg_header = "#1C1C1C"
theme.menu_fg_focus = "#CAD2FC"
theme.menu_bg_focus = "#333333"
theme.menu_bg_alternate = "#1C1C1C"
theme.menu_bg_highlight = "#1C1C1C"
theme.menu_outline_color = "#94A4F9"
theme.menu_fg_track_playing = "#94A4F9"
theme.menu_bg_track_playing = "#1C1C1C"

theme.layout_floating = theme.dir .. "/icons/floating.png"
theme.layout_tile = theme.dir .. "/icons/tile.png"

theme.bottom_bg = "png:" .. theme.dir .."/icons/bottom_bg.png"
theme.top_bg = "png:" .. theme.dir .."/icons/top_bg.png"
theme.icon_clock = theme.dir .."/icons/clock.png"
-- Battery
theme.icon_battery3 = theme.dir .."/icons/battery3.png"
theme.icon_battery2 = theme.dir .."/icons/battery2.png"
theme.icon_battery1 = theme.dir .."/icons/battery1.png"
theme.icon_battery0 = theme.dir .."/icons/battery0.png"
-- Stuff
theme.icon_temp = theme.dir .."/icons/temp.png"

return theme
