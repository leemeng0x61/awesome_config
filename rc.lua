-- author leaveboy 
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")-- Notification library
require("xdgmenu")
vicious = require("vicious")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- DefaultApp
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Mod
modkey = "Mod4"

-- Table
layouts =
{
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier
}
-- }}}

--Tags
tags = {
  names  = { "term", "web", "vbox", "mail", "im", 6, 7, "rss", "media" },
  layout = { layouts[3], layouts[1], layouts[1], layouts[5], layouts[1],
             layouts[7], layouts[7], layouts[6], layouts[7]
}}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
    awful.tag.setproperty(tags[s][5], "mwfact", 0.13)
    awful.tag.setproperty(tags[s][6], "hide",   true)
    awful.tag.setproperty(tags[s][7], "hide",   true)
end
-- }}}

--Menu
myawesomemenu = {
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "restart", awesome.restart },
	{ "quit", awesome.quit }
}
mymainmenu = awful.menu({items ={{"awesome",myawesomemenu,beautiful.awesome_icon },{"applications",xdgmenu},{"open terminal",terminal}}})
mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),menu = mymainmenu })

-- {{{ Wibox
-- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" })
mytextclock = awful.widget.textclock({ align = "right" },"%x %R",60)
-------------------------------------leave--------------------------
--Spacer
spacer    = widget({ type = "textbox" })
separator = widget({ type = "textbox" })
spacer.text     = " "
separator.text  = "┋"

-- CPU usage and temperature
tzswidget = widget({ type = "textbox" })
vicious.register(tzswidget, vicious.widgets.thermal, "$1°C", 19, "thermal_zone0")
-- CPU1
cpu_g1  = awful.widget.graph()
cpu_g1:set_width(40)
cpu_g1:set_height(14)
cpu_g1:set_background_color("#000000")
cpu_g1:set_color("#ff0000")
cpu_g1:set_gradient_angle(0)
cpu_g1:set_gradient_colors({ "#ff0000","#ffffff", "#00ff00"})
vicious.register(cpu_g1,  vicious.widgets.cpu,     "$1")
-- CPU2
cpu_g2  = awful.widget.graph()
cpu_g2:set_width(40)
cpu_g2:set_height(14)
cpu_g2:set_background_color("#000000")
cpu_g2:set_color("#ff0000")
cpu_g2:set_gradient_angle(0)
cpu_g2:set_gradient_colors({ "#ff0000","#ffffff", "#00ff00"})
vicious.register(cpu_g2,  vicious.widgets.cpu,     "$2")
-- CPU3
cpu_g3  = awful.widget.graph()
cpu_g3:set_width(40)
cpu_g3:set_height(14)
cpu_g3:set_background_color("#000000")
cpu_g3:set_color("#ff0000")
cpu_g3:set_gradient_angle(0)
cpu_g3:set_gradient_colors({ "#ff0000","#ffffff", "#00ff00"})
vicious.register(cpu_g3,  vicious.widgets.cpu,     "$3")
-- CPU4
cpu_g4  = awful.widget.graph()
cpu_g4:set_width(40)
cpu_g4:set_height(14)
cpu_g4:set_background_color("#000000")
cpu_g4:set_color("#ff0000")
cpu_g4:set_gradient_angle(0)
cpu_g4:set_gradient_colors({ "#ff0000","#ffffff", "#00ff00"})
vicious.register(cpu_g4,  vicious.widgets.cpu,     "$4")
--Cpu text
cpu = widget({ type = "textbox" })
vicious.register(cpu, vicious.widgets.cpu, ' <span color="brown">CPU1:</span> <span color="orange">$2%</span> <span color="brown">CPU2:</span> <span color="orange">$3%</span>', 1)
-- Battery state
batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, "▌$1$2%", 61, "BAT0")

-- Volume
function volume (mode, widget)
  if mode == "update" then
 	local status = io.popen("amixer sget Master"):read("*all")
        
       local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
       local muted  = string.match(status, "%[(o[^%]]*)%]")

    if muted == "on" then
      volume = '♪' .. volume .. "%"
    else
      volume = '♪' .. "" .. "<span color='red'>".. volume .. "%M</span>"
    end
    widget.text = volume
  elseif mode == "up" then
    io.popen("amixer sset Master,0 5%+"):read("*all")
    volume("update", widget)
  elseif mode == "down" then
    io.popen("amixer sset Master,0 5%-"):read("*all")
    volume("update", widget)
  else
    io.popen("amixer sset Master toggle"):read("*all")
    volume("update", widget)
  end
end
volume_clock = timer({ timeout = 10 })
volume_clock:add_signal("timeout", function () volume("update", tb_volume) end)
volume_clock:start()

tb_volume = widget({ type = "textbox", name = "tb_volume", align = "right" })
--tb_volume.width = 35
tb_volume:buttons(awful.util.table.join(
  awful.button({ }, 4, function () volume("up", tb_volume) end),
  awful.button({ }, 5, function () volume("down", tb_volume) end),
  awful.button({ }, 3, function () awful.util.spawn("pavucontrol") end),
  awful.button({ }, 1, function () volume("mute", tb_volume) end)
))
volume("update", tb_volume)

--MPD
mpd = widget({ type = "textbox" })
vicious.register(mpd, vicious.widgets.mpd,
function (widget, args)
	local ret_str = '<span color="brown">♫</span>'
	if args["{state}"] == "Stop" then
		return ret_str .. '<span color="orange">■</span>'
	elseif args["{state}"] == "Pause" then
	--	return ret_str .. '∥'
	return ret_str ..'<span color="orange">〓</span>'.. args["{Artist}"]..'∙'.. args["{Title}"]
	else
		return ret_str ..'<span color="orange">▶</span>'.. args["{Artist}"]..'∙'.. args["{Title}"]
	end
end, 3)


--Weather
weathericon = widget({ type = "imagebox" })
weathericon.image = image(beautiful.widget_cloud)
weather = widget({type = "textbox" })
vicious.register(weather, vicious.widgets.weather,"${sky} ${tempc} °C"
, 1800,"ZUUU")

--UPTIME
uptime = widget({ type = "textbox" })
vicious.register(uptime, vicious.widgets.uptime,'♨$1-$2:$3', 61)
--MEM
mem = widget({ type = "textbox" })
vicious.register(mem, vicious.widgets.mem, '<span color="brown">▒</span><span color="orange">$1% $2M</span> <span color="brown">♻</span><span color="orange">$5% $6M</span>', 1)
--FS
fs = widget({ type = "textbox" })
vicious.register(fs, vicious.widgets.fs, '<span color="brown">FS:</span><span color="orange">${/ used_gb}G ${/ used_p}%</span>', 5)
--DIO
dio = widget({ type = "textbox" })
vicious.register(dio, vicious.widgets.dio, '<span color="brown">◘</span><span color="green">↑${sda read_kb}</span><span color="orange">↓${sda write_kb}</span>', 1, "sda")
--NET
net = widget({ type = "textbox" })
vicious.register(net, vicious.widgets.net, '<span color="brown">Ψ</span><span color="green">↓${wlan0 down_kb}</span><span color="orange">↑${wlan0 up_kb}</span>', 1)
--VOLUME
-------------------------------------leave--------------------------

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox_top = {}
mywibox_bottom = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
 
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
 
    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)





 
    -- Create the wibox
    mywibox_top[s] = awful.wibox({ position = "top", screen = s })
    mywibox_bottom[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
        -- top
      mywibox_top[s].widgets = {
		{
			mylauncher,
			mytaglist[s],
			mypromptbox[s],
			layout = awful.widget.layout.horizontal.leftright
		},
		mylayoutbox[s],
		mytextclock,
		s == 1 and mysystray or nil,
		separator,tb_volume,
		separator,batwidget,
		separator,uptime,
		separator,weather,
		mytasklist[s],
		layout = awful.widget.layout.horizontal.rightleft
	}
	--bottom
	mywibox_bottom[s].widgets = {
		{
			--fs,separator,
			mem,separator,
			dio,separator,
			net,separator,
			mpd,
			layout = awful.widget.layout.horizontal.leftright
		},
		cpu_g1.widget,
		spacer,cpu_g2.widget,
		spacer,cpu_g3.widget,
		spacer,cpu_g4.widget,
		tzswidget,
		layout = awful.widget.layout.horizontal.rightleft
	}
end
-- }}}
 
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
 
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
 
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),
        -- Unminimize clients
        awful.key({ modkey, "Control" }, "m",
        function ()
            local allclients = client.get(mouse.screen)
            for _, c in ipairs(allclients) do
                if c.minimized and c:tags()[mouse.screen] == awful.tag.selected(mouse.screen) then
                    c.minimized = false
                    client.focus = c
                    c:raise()
                    return
                end
            end
        end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
--volume ctrl
awful.key({ }, "XF86AudioLowerVolume",function()awful.util.spawn("amixer sset Master,0 5%-")end),
awful.key({ }, "XF86AudioRaiseVolume",function()awful.util.spawn("amixer sset Master,0 5%+")end),
awful.key({ }, "XF86AudioMute",       function()awful.util.spawn("amixer sset Master toggle")end),
awful.key({ }, "XF86AudioPlay",       function()awful.util.spawn("mpc toggle")end),
awful.key({ }, "XF86AudioNext",       function()awful.util.spawn("mpc next")end),
awful.key({ }, "XF86AudioPrev",       function()awful.util.spawn("mpc prev")end),
awful.key({ }, "XF86Display",         function()awful.util.spawn("xrandr --output VGA1 --auto --left-of LVDS1")end),
awful.key({ }, "XF86ScreenSaver",     function()awful.util.spawn("xscreensaver-command --lock")end),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
        -- 截图 {{{3
        awful.key({ }, "Print", function ()
            -- 截图：全屏
            awful.util.spawn("zsh -c 'cd ~/tmpfs&&scrot fullsc.png'")
            os.execute("sleep .5")
            naughty.notify({title="截图", text="全屏截图已保存。"})
        end),
        awful.key({ "Shift", }, "Print", function ()
            -- 截图：当前窗口
            awful.util.spawn("zsh -c 'cd ~/tmpfs&&scrot -u'")
            os.execute("sleep .5")
            naughty.notify({title="截图", text="当前窗口截图已保存。"})
        end),
 
        -- {{{3 sdcv
        awful.key({ modkey }, "d", function ()
            local f = io.popen("xsel -p")
            local new_word = f:read("*a")
            f:close()
 
            if frame ~= nil then
                naughty.destroy(frame)
                frame = nil
                if old_word == new_word then
                    return
                end
            end
            old_word = new_word
 
            local fc = ""
            local f = io.popen("sdcv -n --utf8-output -u 'stardict1.3英汉辞典' "..new_word)
            for line in f:lines() do
                fc = fc .. line .. '\n'
            end
            f:close()
            frame = naughty.notify({ text = fc, timeout = 5, width = 320 })
        end),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
 
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
 
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
	--	awful.key({ "Control", "Shift"}, "space", function () awful.util.spawn("synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')")end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
 
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end
 
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
--client.add_signal("focus",   function(c) c.border_color = beautiful.border_focus c.opacity = 1 end)
--client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal c.opacity = 0.7 end)
-- }}}
floatapps =
{
    ["MPlayer"] = true,
    ["gimp"] = true,
    ["smplayer"] = true,
    ["mocp"] = true,
    ["Codeblocks"] = true,
    ["Dialog"] = true,
    ["Download"] = true,
    ["empathy"] = true,
}
 
-- 把指定的程序自动移动到某个特定的屏幕的某个tag上面
apptags =
{
    ["smplayer"] = { screen = 1, tag = 7 },
    ["amarokapp"] = { screen = 1, tag = 8 },
    ["VirtualBox"] = { screen = 1, tag = 9 },
    ["Firefox"] = { screen = 1, tag = 1},
    ["Thunderbird-bin"] = { screen = 1, tag = 7 },
    ["Linux-fetion"] = { screen = 1, tag = 6 },
}
do
  local cmds = 
  { 
    "xcompmgr -Ss -n -Cc -fF -I-10 -O-10 -D1 -t-3 -l-4 -r4 &",
    --and so on...
  }

  for _,i in pairs(cmds) do
    awful.util.spawn(i)
  end
end
