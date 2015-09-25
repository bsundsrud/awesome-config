 -- Creates a volume display widget
 -- Copied/adapted from https://awesome.naquadah.org/wiki/Davids_volume_widget
 ---------------------------------
 
 local awful = require("awful")
 
 -- Color constants
 local normal_color = '#33cc33'
 local over_100_color = '#3333cc'
 local mute_color = '#cc3333'
 local background_color = '#222222'
 local background_over_100_color = normal_color
 local volume_lib = {} 
 -- Functions to fetch volume information (pulseaudio)
 function volume_lib.get_volume() -- returns the volume as a float (1.0 = 100%)
     local fd = io.popen("pactl list | grep -A 9001 'Sink #0' | grep Volume | head -n 1 | awk '{print $3}' | sed 's/[^0-9]*//g'")
     local volume_str = fd:read("*all")
     fd:close()
     return tonumber(volume_str) / 100
 end
 
 function volume_lib.get_mute() -- returns a true value if muted or a false value if not
     fd = io.popen("pactl list | grep -A 9001 'Sink #0' | grep Mute | head -n 1")
     local mute_str = fd:read("*all")
     fd:close()
     return string.find(mute_str, "yes")
 end
 
 -- Updates the volume widget's display
 function volume_lib.update_volume(widget)
     local volume = volume_lib.get_volume()
     local mute = volume_lib.get_mute()
 
     -- color
     color = normal_color
     bg_color = background_color
     if volume > 1 then
         color = over_100_color
         bg_color = background_over_100_color
         volume = volume % 1
     end
     color = (mute and mute_color) or color
 
     widget:set_color(color)
     widget:set_background_color(bg_color)
 
     widget:set_value(volume)
 end
 
 -- Volume control functions for external use
 function volume_lib.inc_volume(widget)
     awful.util.spawn("pactl set-sink-volume 0 -- +3%", false)
     volume_lib.update_volume(widget)
 end
 
 function volume_lib.dec_volume(widget)
     awful.util.spawn("pactl set-sink-volume 0 -- -3%", false)
    volume_lib. update_volume(widget)
 end
 
 function volume_lib.mute_volume(widget)
     awful.util.spawn("pactl set-sink-mute 0 toggle", false)
     volume_lib.update_volume(widget)
 end
 
 function volume_lib.create_volume_widget()
     -- Define volume widget
     volume_widget = awful.widget.progressbar()
     volume_widget:set_width(8)
     volume_widget:set_vertical(true)
     volume_widget:set_border_color('#666666')
 
     -- Init the widget
     volume_lib.update_volume(volume_widget)
 
     -- Update the widget on a timer
     mytimer = timer({ timeout = 1 })
     mytimer:connect_signal("timeout", function () volume_lib.update_volume(volume_widget) end)
     mytimer:start()
 
     return volume_widget
 end

 return volume_lib
