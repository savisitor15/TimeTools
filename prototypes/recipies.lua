data:extend(
{
	---------------------------------------------------------------------------------
	{
		type = "recipe",
		name = "clock-combinator",
		enabled = "false",
		ingredients =
		{
			{"copper-cable", 5},
			{"electronic-circuit", 2},
		},
		result = "clock-combinator"
	},
	
}
)

table.insert( data.raw["technology"]["circuit-network"].effects, { type = "unlock-recipe", recipe = "clock-combinator" } )

