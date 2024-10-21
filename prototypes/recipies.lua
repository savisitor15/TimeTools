data:extend(
{
	---------------------------------------------------------------------------------
	{
		type = "recipe",
		name = "clock-combinator",
		enabled = false,
		ingredients =
		{
			{type = "item", name = "copper-cable", amount = 5},
      		{type = "item", name = "electronic-circuit", amount = 2}
		},
		results = {{type = "item", name = "clock-combinator", amount = 1}}
	},
	
}
)

table.insert( data.raw["technology"]["circuit-network"].effects, { type = "unlock-recipe", recipe = "clock-combinator" } )

