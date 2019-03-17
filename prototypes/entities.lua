data:extend(
{
	----------------------------------------------------------------------------------
	{
		type = "constant-combinator",
		name = "clock-combinator",
		icon = "__TimeTools__/graphics/clock-combinator-icon.png",
		icon_size = 32,
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "clock-combinator"},
		max_health = 50,
		corpse = "small-remnants",

		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

		item_slot_count = 15,

		sprites =
		{
			north =
			{
				filename = "__TimeTools__/graphics/clock-combinator.png",
				x = 61,
				width = 61,
				height = 50,
				shift = {0.078125, 0.15625},
			},
			east =
			{
				filename = "__TimeTools__/graphics/clock-combinator.png",
				x = 61,
				width = 61,
				height = 50,
				shift = {0.078125, 0.15625},
			},
			south =
			{
				filename = "__TimeTools__/graphics/clock-combinator.png",
				x = 61,
				width = 61,
				height = 50,
				shift = {0.078125, 0.15625},
			},
			west =
			{
				filename = "__TimeTools__/graphics/clock-combinator.png",
				x = 61,
				width = 61,
				height = 50,
				shift = {0.078125, 0.15625},
			},
		},
		
    activity_led_sprites =
    {
      north =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
      width = 8,
      height = 6,
      frame_count = 1,
      shift = util.by_pixel(9, -12),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-N.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = util.by_pixel(9, -11.5)
      }
    },
    east =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(8, 0),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(7.5, -0.5)
      }
    },
    south =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-9, 2),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-S.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-9, 2.5)
      }
    },
    west =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-7, -15),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-W.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-7, -15)
      }
    }
    },
	
    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire =
        {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },
	circuit_wire_max_distance = 7.5
	},

}
)

