data:extend(
	{
		{
			type = "font",
			name = "timetools_font",
			from = "default",
			border = false,
			size = 15
		},
		{
			type = "font",
			name = "timetools_font_bold",
			from = "default-bold",
			border = false,
			size = 15
		},
		
		{
			type = "sprite",
			name = "sprite_timetools_alwday",
			filename = "__TimeTools__/graphics/but-alwday.png",
			width = 22,
			height = 30,
		},
		{
			type = "sprite",
			name = "sprite_timetools_night",
			filename = "__TimeTools__/graphics/but-night.png",
			width = 22,
			height = 30,
		},
	}
)

local default_gui = data.raw["gui-style"].default

default_gui.timetools_sprite_style = 
{
	type="button_style",
	parent="button",
	top_padding = 1,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	width = 36,
	height = 36,
	scalable = false,
}

default_gui.timetools_flow_style = 
{
	type="horizontal_flow_style",
	parent="horizontal_flow",
	top_padding = 5,
	bottom_padding = 5,
	left_padding = 5,
	right_padding = 5,
	
	horizontal_spacing = 0,
	vertical_spacing = 0,
	max_on_row = 0,
	resize_row_to_width = true,
	
	graphical_set = { type = "none" },
}
default_gui.timetools_botton_time_style=
{
	type="button_style",
	parent="button",
	font="timetools_font_bold",
	align = "center",
	top_padding = 1,
	bottom_padding = 0,
	left_padding = 0,
	right_padding = 0,
	height = 36,
	minimal_width = 72,
	scalable = false,
	left_click_sound =
	{
		{
		  filename = "__core__/sound/gui-click.ogg",
		  volume = 1
		}
	},
}

default_gui.timetools_button_style = 
{
	type="button_style",
	parent="button",
	font="timetools_font_bold",
	align = "center",
	top_padding = 1,
	bottom_padding = 0,
	left_padding = 0,
	right_padding = 0,
	height = 36,
	minimal_width = 36,
	scalable = false,
	left_click_sound =
	{
		{
		  filename = "__core__/sound/gui-click.ogg",
		  volume = 1
		}
	},
}

