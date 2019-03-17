-- debug_status = 1
debug_mod_name = "TimeToolsContinued"
debug_file = debug_mod_name .. "-debug.txt"
require("utils")
require("config")

local ticks_per_day = 25000

--------------------------------------------------------------------------------------
local function init_day()
	global.day = 1+math.floor((game.tick+12500) / ticks_per_day)
end

--------------------------------------------------------------------------------------
local function get_time()
	-- daytime : 0.0 to 1.0, noon to noon (midnight at 0.5), max light to min light to max light...
	-- game starts at daytime = 0, so noon of day 1.
		
	local daytime
	local always_day = global.surface.always_day
			
	if global.always_day ~= always_day then
		global.refresh_always_day = true
	end
		
	if always_day then
		daytime = game.tick / 25000
		daytime = daytime - math.floor(daytime)
	else
		if global.always_day == true then
			daytime = ((global.h + 12) + (global.m / 60)) / 24
			global.surface.daytime = daytime - math.floor(daytime)
		end
		daytime = global.surface.daytime
	end
		
	daytime = (daytime*24+12) % 24
	global.h = math.floor(daytime)
	global.m = math.floor((daytime-global.h)*60)
		
	if global.h == 0 and global.h_prev == 23 then
		global.day = global.day + 1
	end
	
	global.always_day = always_day
	global.h_prev = global.h
end

--------------------------------------------------------------------------------------
local function init_globals()
	-- initialize or update general globals of the mod
	debug_print( "init_globals" )
	
	global.ticks = global.ticks or 0
	global.cycles = global.cycles or 0
	global.surface = game.surfaces.nauvis

	if global.offset == nil then global.offset = 0 end
	if global.h == nil then global.h = 12 end
	if global.m == nil then global.m = 0 end
	global.h_prev = global.h_prev or 23
	global.always_day = global.always_day or -1 -- -1 to force update of the icon at first install
	global.refresh_always_day = true
	
	if not always_day_enabled then global.surface.always_day = false end
	
	if global.day == nil then 
		init_day() 
		get_time()
	end
	
	if global.frozen == nil then global.frozen = false end
	if global.display == nil then global.display = true end
	global.clocks = global.clocks or {}
	
	global.speed_mem = global.speed_mem or maximum_speed
end

--------------------------------------------------------------------------------------
local function init_player(player)
	if global.ticks == nil then return end
	
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
			
			global.always_day = -1 -- to force update of icon

			init_forces()

			-- migrations
			for _, player in pairs(game.players) do
				if player.gui.top.timebar_frame then player.gui.top.timebar_frame.destroy() end -- destroy old bar
			end
			
			if changes.old_version ~= nil and older_version(changes.old_version, "1.0.17") then
				for _, player in pairs(game.players) do
					if player.gui.top.timetools_frame then player.gui.top.timetools_frame.destroy() end -- destroy old bar
				end
			end

			if changes.old_version ~= nil and older_version(changes.old_version, "1.0.18") then
				init_day()
			end

			if changes.old_version ~= nil and older_version(changes.old_version, "1.0.23") then
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
		
		table.insert( global.clocks, 
			{
				entity = ent, 
			}
		)
		
		debug_print( "clocks=" .. #global.clocks )
	end
end

script.on_event(defines.events.on_built_entity, on_creation )
script.on_event(defines.events.on_robot_built_entity, on_creation )

--------------------------------------------------------------------------------------
local function on_destruction( event )
	local ent = event.entity
	
	if ent.name == "clock-combinator" then
		debug_print( "clock-combinator destroyed" )
		
		for i, clock in ipairs(global.clocks) do
			if clock.entity == ent then
				table.remove( global.clocks, i )
				break
			end
		end
		
		debug_print( "clocks=" .. #global.clocks )
	end
end

script.on_event(defines.events.on_entity_died, on_destruction )
script.on_event(defines.events.on_robot_pre_mined, on_destruction )
script.on_event(defines.events.on_pre_player_mined_item, on_destruction )

--------------------------------------------------------------------------------------
local function on_tick(event)
	if global.ticks <= 0 then
		global.ticks = clock_cycle_in_ticks
	elseif global.ticks == 2 then
		get_time()

		-- update time display on button
		
		if global.display then
			local s_time = string.format("%u-%02u:%02u", global.day, global.h, global.m )
			local flow
			
			for _, player in pairs(game.players) do
				if player.connected and player.gui.top.timetools_flow then
					flow = player.gui.top.timetools_flow
					flow.but_time.caption = s_time
					
					if global.refresh_always_day then
						if global.surface.always_day then
							flow.but_always.sprite = "sprite_timetools_alwday"
						else
							flow.but_always.sprite = "sprite_timetools_night"
						end
					end
					
					if debug_status then
						flow.but_tick.caption = game.tick
					end
				end
			end
			
			global.refresh_always_day = false
		end

	elseif global.ticks == 4 then
		if global.cycles <= 0 then
			global.cycles = clock_combinator_cycle
			-- update clocks variables
			for i, clock in pairs(global.clocks) do
				if clock.entity.valid then
					params = {parameters={
						{index=1,signal={type="virtual",name="signal-clock-gametick"},count=math.floor(game.tick)},
						{index=2,signal={type="virtual",name="signal-clock-day"},count=global.day},
						{index=3,signal={type="virtual",name="signal-clock-hour"},count=global.h},
						{index=4,signal={type="virtual",name="signal-clock-minute"},count=global.m},
						{index=5,signal={type="virtual",name="signal-clock-alwaysday"},count=iif(global.surface.always_day,1,0)},
						{index=6,signal={type="virtual",name="signal-clock-darkness"},count=math.floor(global.surface.darkness*100)},
						{index=7,signal={type="virtual",name="signal-clock-lightness"},count=math.floor((1-global.surface.darkness)*100)},
					}}
					
					clock.entity.get_control_behavior().parameters = params
				else
					table.remove(global.clocks,i)
				end
			end
		else
			global.cycles = global.cycles - 1
		end
	end
	
	global.ticks = global.ticks - 1
end

script.on_event(defines.events.on_tick, on_tick)

--------------------------------------------------------------------------------------
local function on_gui_click(event)
	if event.element.name == "but_time" then
		if not global.surface.always_day then
			global.frozen = not global.frozen
		global.surface.freeze_daytime = global.frozen
			update_guis()
		end
		
	elseif event.element.name == "but_always" then
		if always_day_enabled then
			global.surface.always_day = not global.surface.always_day
		
			if global.surface.always_day then
				global.frozen = false
			end
		end
		update_guis()
		
	elseif event.element.name == "but_slower" then
		if game.speed >= 0.2 then game.speed = game.speed / 2 end -- minimum 0.1
		if game.speed ~= 1 then global.speed_mem = game.speed end
		update_guis()
		
	elseif event.element.name == "but_faster" then
		if game.speed < maximum_speed then game.speed = game.speed * 2 end
		if game.speed ~= 1 then global.speed_mem = game.speed end
		update_guis()

	elseif event.element.name == "but_speed" then
		if game.speed == 1 then game.speed = global.speed_mem else game.speed = 1 end
		update_guis()
	end
	
end

script.on_event(defines.events.on_gui_click, on_gui_click )

--------------------------------------------------------------------------------------
function build_gui( player )
	local gui1 = player.gui.top.timetools_flow
	
	if gui1 == nil and global.display then
		debug_print("create frame player" .. player.name)
		gui1 = player.gui.top.add({type = "flow", name = "timetools_flow", direction = "horizontal", style = "timetools_flow_style"})
		local gui2 = gui1.add({type = "button", name = "but_time", caption = "0-00:00", font_color = colors.white, style = "timetools_button_style"})				
		if global.frozen then
			gui2.style.font_color = colors.lightred
		else
			gui2.style.font_color = colors.green
		end
		gui2 = gui1.add({type = "sprite-button", name = "but_always", style = "timetools_sprite_style"})
		if global.surface.always_day then
			gui2.sprite = "sprite_timetools_alwday"
		else
			gui2.sprite = "sprite_timetools_night"
		end
		gui1.add({type = "button", name = "but_slower", caption = "<" , font_color = colors.white, style = "timetools_button_style"})
		gui1.add({type = "button", name = "but_faster", caption = ">" , font_color = colors.white, style = "timetools_button_style"})
		gui1.add({type = "button", name = "but_speed", caption = "x1" , font_color = colors.white, style = "timetools_button_style"})
		if debug_status then
			gui1.add({type = "button", name = "but_tick", caption = "0" , font_color = colors.white, style = "timetools_button_style"})
		end
	end
	return( gui1 )
end
	
--------------------------------------------------------------------------------------
function update_guis()
	if global.display then
		for _, player in pairs(game.players) do
			if player.connected then
				local flow = build_gui(player)
				local s
				
				if game.speed == 1 then
					flow.but_speed.caption = "x1"
					flow.but_speed.style.font_color = colors.white
				elseif game.speed < 1 then
					s = string.format("/%1.0f", 1/game.speed )
					flow.but_speed.caption = s
					flow.but_speed.style.font_color = colors.green
				elseif game.speed > 1 then
					s = string.format("x%1.0f", game.speed )
					flow.but_speed.caption = s
					flow.but_speed.style.font_color = colors.lightred
				end
		
				if global.surface.always_day then
					flow.but_always.sprite = "sprite_timetools_alwday"
				else
					flow.but_always.sprite = "sprite_timetools_night"
				end

				if global.frozen then
					flow.but_time.style.font_color = colors.lightred
				else
					flow.but_time.style.font_color = colors.green
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
	
	global.surface.always_day = false
	global.surface.daytime = math.min((((hh+12)%24) * 60 + mm) / 24 / 60,1)
	global.frozen = false
	global.h = hh
	global.m = mm
	
	update_guis()
end

function interface.setfrozen( frozen )
	debug_print( "frozen" )
	
	global.frozen = frozen
	
	update_guis()
end

function interface.off( )
	debug_print( "off" )
	
	global.display = false
	
	for _, player in pairs(game.players) do
		if player.connected and player.gui.top.timetools_flow then player.gui.top.timetools_flow.destroy() end
	end
end

function interface.on( )
	debug_print( "on" )

	global.display = true
	
	update_guis()
end


remote.add_interface( "timetools", interface )

-- /c remote.call( "timetools", "setclock", 20.15 )
-- /c remote.call( "timetools", "reset" )
-- /c remote.call( "timetools", "on" )
-- /c remote.call( "timetools", "off" )
-- /c remote.call( "timetools", "setfrozen", true )

