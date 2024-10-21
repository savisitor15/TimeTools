--debug_status = 1
debug_mod_name = "TimeTools"
debug_file = debug_mod_name .. "-debug.txt"
require("utils")
--require("config")

local ticks_per_day = 25000

--------------------------------------------------------------------------------------
local function init_day()
	storageday = 1 + math.floor((game.tick+(ticks_per_day/2)) / ticks_per_day)
end

--------------------------------------------------------------------------------------
local function get_time()
	-- daytime : 0.0 to 1.0, noon to noon (midnight at 0.5), max light to min light to max light...
	-- game starts at daytime = 0, so noon of day 1.
		
	local daytime
	local always_day = storagesurface.always_day or 0
			
	if storagealways_day ~= always_day then
		storagerefresh_always_day = true
	end
		
	if always_day then
		daytime = game.tick / ticks_per_day
		daytime = daytime - math.floor(daytime)
	else
		if storagealways_day == true then
			daytime = ((storageh + 12) + (storagem / 60)) / 24
			storagesurface.daytime = daytime - math.floor(daytime)
		end
		daytime = storagesurface.daytime
	end
		
	daytime = (daytime*24+12) % 24
	storageh = math.floor(daytime)
	storagem = math.floor((daytime-storageh)*60)
	-- day calculation independant of hour
	storageday = math.floor((game.tick+(ticks_per_day/2)) / ticks_per_day) + 1
	
	storagealways_day = always_day
	storageh_prev = storageh
end

--------------------------------------------------------------------------------------
local function init_globals()
	-- initialize or update general globals of the mod
	debug_print( "init_globals" )
	
	storageticks = storageticks or 0
	storagecycles = storagecycles or 0
	storagesurface = game.surfaces.nauvis

	if storageoffset == nil then storageoffset = 0 end
	if storageh == nil then storageh = 12 end
	if storagem == nil then storagem = 0 end
	storageh_prev = storageh_prev or 23
	storagealways_day = storagealways_day or -1 -- -1 to force update of the icon at first install
	storagerefresh_always_day = true
	
	if not settings.global["timetools-always-day"].value then storagesurface.always_day = false end
	
	if storageday == nil then 
		init_day() 
		get_time()
	end
	
	if storagefrozen == nil then storagefrozen = false end
	if storagedisplay == nil then storagedisplay = true end
	storageclocks = storageclocks or {}
	
	storagespeed_mem = storagespeed_mem or settings.global["timetools-maximum-speed"].value
end

--------------------------------------------------------------------------------------
local function init_player(player)
	if storageticks == nil then return end
	
	-- initialize or update per player globals of the mod, and reset the gui
	debug_print( "init_player ", player.name, " connected=", player.connected )
	
	if player.connected then
		build_gui(player)
	end
end

--------------------------------------------------------------------------------------
local function init_players()
	for _, player in pairs(game.players) do
		init_player(player)
	end
end

--------------------------------------------------------------------------------------
local function init_forces()
	for _,force in pairs(game.forces) do
		force.recipes["clock-combinator"].enabled = force.technologies["circuit-network"].researched
	end
end

--------------------------------------------------------------------------------------
local function on_init() 
	-- called once, the first time the mod is loaded on a game (new or existing game)
	debug_print( "on_init" )
	init_globals()
	init_forces()
	init_players()
end

script.on_init(on_init)

--------------------------------------------------------------------------------------
local function on_configuration_changed(data)
	-- detect any mod or game version change
	if data.mod_changes ~= nil then
		local changes = data.mod_changes[debug_mod_name]
		if changes ~= nil then
			debug_print( "update mod: ", debug_mod_name, " ", tostring(changes.old_version), " to ", tostring(changes.new_version) )
		
			init_globals()
			
			storagealways_day = -1 -- to force update of icon

			init_forces()

			-- migrations
			for _, player in pairs(game.players) do
				if player.gui.top.timebar_frame then player.gui.top.timebar_frame.destroy() end -- destroy old bar
			end
			if changes.old_version ~= nil and older_version(changes.old_version, "1.0.18") then
				init_day()
			end
			if changes.old_version ~= nil and older_version(changes.old_version, "1.0.34") then
				for _, player in pairs(game.players) do
					if player.gui.top.timetools_flow then player.gui.top.timetools_flow.destroy() end -- rebuild bar
				end
			end
			if changes.old_version ~= nil and older_version(changes.old_version, "2.0.41") then
				for _, player in pairs(game.players) do
					if player.gui.top.timetools_flow then player.gui.top.timetools_flow.destroy() end -- rebuild bar
				end
			end
			init_players()

			update_guis()			
		end
	end
end

script.on_configuration_changed(on_configuration_changed)

--------------------------------------------------------------------------------------
local function on_player_created(event)
	-- called at player creation
	local player = game.players[event.player_index]
	debug_print( "player created ", player.name )
	
	init_player(player)
end

script.on_event(defines.events.on_player_created, on_player_created )

--------------------------------------------------------------------------------------
local function on_player_joined_game(event)
	-- called in SP(once) and MP(every connect), eventually after on_player_created
	local player = game.players[event.player_index]
	debug_print( "player joined ", player.name )
	
	init_player(player)
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game )

--------------------------------------------------------------------------------------
local function on_creation( event )
	local ent = event.created_entity
	
	if ent.name == "clock-combinator" then
		debug_print( "clock-combinator created" )
		
		table.insert( storageclocks, 
			{
				entity = ent, 
			}
		)
		
		debug_print( "clocks=" .. #storageclocks )
	end
end

script.on_event(defines.events.on_built_entity, on_creation )
script.on_event(defines.events.on_robot_built_entity, on_creation )

--------------------------------------------------------------------------------------
local function on_destruction( event )
	local ent = event.entity
	
	if ent.name == "clock-combinator" then
		debug_print( "clock-combinator destroyed" )
		
		for i, clock in ipairs(storageclocks) do
			if clock.entity == ent then
				table.remove( storageclocks, i )
				break
			end
		end
		
		debug_print( "clocks=" .. #storageclocks )
	end
end

script.on_event(defines.events.on_entity_died, on_destruction )
script.on_event(defines.events.on_robot_pre_mined, on_destruction )
script.on_event(defines.events.on_pre_player_mined_item, on_destruction )

--------------------------------------------------------------------------------------
local function format_time()
	local sTime = ""
	sTime = string.format("%u-%02u:%02u", storageday, storageh, storagem )
	return sTime
end

local function on_tick(event)
	if storagespeed_mem > settings.global["timetools-maximum-speed"].value then
		-- User changed the speed mid acceleration or on the fly
		storagespeed_mem = settings.global["timetools-maximum-speed"].value
		if  game.speed > storagespeed_mem then
			game.speed = storagespeed_mem
			update_guis()
		end
	end
	if (game.tick % settings.global["timetools-clock-update-interval"].value) == 0 then
		get_time()

		-- update time display on button
		
		if storagedisplay then
			local s_time = format_time()
			local flow
			
			for _, player in pairs(game.players) do
				if player.connected and player.gui.top.timetools_flow then
					flow = player.gui.top.timetools_flow
					if flow.timetools_but_time == nil or (debug_status and flow.timetools_but_tick == nil) then
						flow.destroy()
						init_player(player)
						update_guis()
						flow = player.gui.top.timetools_flow -- re-assign
					end
					flow.timetools_but_time.caption = s_time
					
					if storagerefresh_always_day then
						if storagesurface.always_day then
							flow.timetools_but_always.sprite = "sprite_timetools_alwday"
						else
							flow.timetools_but_always.sprite = "sprite_timetools_night"
						end
					end
					if debug_status then
						flow.timetools_but_tick.caption = game.tick
					end
				end
			end
			
			storagerefresh_always_day = false
		end
	end
	if (game.tick % settings.global["timetools-combinator-interval"].value)  == 0 then
			for i, clock in pairs(storageclocks) do
				if clock.entity.valid then
					params = {
						{index=1,signal={type="virtual",name="signal-clock-gametick"},count=math.floor(game.tick)},
						{index=2,signal={type="virtual",name="signal-clock-day"},count=storageday},
						{index=3,signal={type="virtual",name="signal-clock-hour"},count=storageh},
						{index=4,signal={type="virtual",name="signal-clock-minute"},count=storagem},
						{index=5,signal={type="virtual",name="signal-clock-alwaysday"},count=iif(storagesurface.always_day,1,0)},
						{index=6,signal={type="virtual",name="signal-clock-darkness"},count=math.floor(storagesurface.darkness*100)},
						{index=7,signal={type="virtual",name="signal-clock-lightness"},count=math.floor((1-storagesurface.darkness)*100)},
					}
					clock.entity.get_control_behavior().parameters = params
				else
					table.remove(storageclocks,i)
				end
			end
	end
end

script.on_event(defines.events.on_tick, on_tick)

--------------------------------------------------------------------------------------
local function on_gui_click(event)
	local player = game.players[event.player_index]
	if string.match(event.element.name, "timetools_") == nil then
		-- not for us
		return
	end
	if player.admin then
		if event.element.name == "timetools_but_time" then
			if not storagesurface.always_day then
				storagefrozen = not storagefrozen
			storagesurface.freeze_daytime = storagefrozen
				update_guis()
			end
			
		elseif event.element.name == "timetools_but_always" then
			if settings.global["timetools-always-day"].value then
				storagesurface.always_day = not storagesurface.always_day
			
				if storagesurface.always_day then
					storagefrozen = false
				end
			end
			update_guis()
			
		elseif event.element.name == "timetools_but_slower" then
			if game.speed >= 0.2 then game.speed = game.speed / 2 end -- minimum 0.1
			if game.speed ~= 1 then storagespeed_mem = game.speed end
			update_guis()
			
		elseif event.element.name == "timetools_but_faster" then
			if game.speed < settings.global["timetools-maximum-speed"].value then game.speed = game.speed * 2 end
			if game.speed ~= 1 then storagespeed_mem = game.speed end
			update_guis()

		elseif event.element.name == "timetools_but_speed" then
			if game.speed == 1 then game.speed = storagespeed_mem else game.speed = 1 end
			update_guis()
		end
	else
		player.print({"mod-messages.timetools-message-admins-only"})
	end
end

script.on_event(defines.events.on_gui_click, on_gui_click )

--------------------------------------------------------------------------------------
function build_gui( player )
	local gui1 = player.gui.top.timetools_flow
	
	if gui1 == nil and storagedisplay then
		debug_print("create frame player" .. player.name)
		gui1 = player.gui.top.add({type = "flow", name = "timetools_flow", direction = "horizontal", style = "timetools_flow_style"})
		local gui2 = gui1.add({type = "button", name = "timetools_but_time", caption = "0-00:00", font_color = colors.white, style = "timetools_botton_time_style"})				
		if storagefrozen then
			gui2.style.font_color = colors.lightred
		else
			gui2.style.font_color = colors.green
		end
		gui2 = gui1.add({type = "sprite-button", name = "timetools_but_always", style = "timetools_sprite_style"})
		if storagesurface.always_day then
			gui2.sprite = "sprite_timetools_alwday"
		else
			gui2.sprite = "sprite_timetools_night"
		end
		gui1.add({type = "button", name = "timetools_but_slower", caption = "<" , font_color = colors.white, style = "timetools_button_style"})
		gui1.add({type = "button", name = "timetools_but_faster", caption = ">" , font_color = colors.white, style = "timetools_button_style"})
		gui1.add({type = "button", name = "timetools_but_speed", caption = "x1" , font_color = colors.white, style = "timetools_button_style"})
		if debug_status then
			gui1.add({type = "button", name = "timetools_but_tick", caption = "0" , font_color = colors.white, style = "timetools_button_style"})
		end
	end
	return( gui1 )
end
	
--------------------------------------------------------------------------------------
function update_guis()
	if storagedisplay then
		for _, player in pairs(game.players) do
			if player.connected then
				local flow = build_gui(player)
				local s
				
				if game.speed == 1 then
					flow.timetools_but_speed.caption = "x1"
					flow.timetools_but_speed.style.font_color = colors.white
				elseif game.speed < 1 then
					s = string.format("/%1.0f", 1/game.speed )
					flow.timetools_but_speed.caption = s
					flow.timetools_but_speed.style.font_color = colors.green
				elseif game.speed > 1 then
					s = string.format("x%1.0f", game.speed )
					flow.timetools_but_speed.caption = s
					flow.timetools_but_speed.style.font_color = colors.lightred
				end
		
				if storagesurface.always_day then
					flow.timetools_but_always.sprite = "sprite_timetools_alwday"
				else
					flow.timetools_but_always.sprite = "sprite_timetools_night"
				end

				if storagefrozen then
					flow.timetools_but_time.style.font_color = colors.lightred
				else
					flow.timetools_but_time.style.font_color = colors.green
				end
			end
		end	
	end
end

--------------------------------------------------------------------------------------

local interface = {}

function interface.reset()
	debug_print( "reset" )
	
	init_day()
	
	for _,force in pairs(game.forces) do
		force.reset_recipes()
		force.reset_technologies()
	end
	
	for _, player in pairs(game.players) do
		if player.gui.top.timetools_flow then	
			player.gui.top.timetools_flow.destroy()
		end
	end
	
	update_guis()
end

function interface.setclock( hhmm )
	debug_print( "setclock" )
	
	if hhmm == nil then hhmm = 0 end
	if hhmm < 0 then hhmm = 0 end
	if hhmm >= 24 then hhmm = 23.59 end
	
	local mm = (hhmm - math.floor(hhmm)) * 100
	local hh = math.floor(hhmm)
	
	if mm >= 60 then mm = 59 end
	
	storagesurface.always_day = false
	storagesurface.daytime = math.min((((hh+12)%24) * 60 + mm) / 24 / 60,1)
	storagefrozen = false
	storageh = hh
	storagem = mm
	
	update_guis()
end

function interface.setspeed(speed)
	debug_print( "set time" )
	if speed == nil then speed = 1 end
	speed = math.floor(speed) -- ensure integer
	if speed < 1 then speed = 1 end
	if speed > settings.global["timetools-maximum-speed"].value then
		speed = settings.global["timetools-maximum-speed"].value
	end
	storagespeed = speed
	update_guis()
end

function interface.setfrozen( frozen )
	debug_print( "frozen" )
	
	storagefrozen = frozen
	
	update_guis()
end

function interface.off( )
	debug_print( "off" )
	
	storagedisplay = false
	
	for _, player in pairs(game.players) do
		if player.connected and player.gui.top.timetools_flow then player.gui.top.timetools_flow.destroy() end
	end
end

function interface.on( )
	debug_print( "on" )

	storagedisplay = true
	
	update_guis()
end


remote.add_interface( "timetools", interface )

-- /c remote.call( "timetools", "setclock", 20.15 )
-- /c remote.call( "timetools", "reset" )
-- /c remote.call( "timetools", "on" )
-- /c remote.call( "timetools", "off" )
-- /c remote.call( "timetools", "setfrozen", true )
-- /c remote.call( "timetools", "setspeed", 2 )

