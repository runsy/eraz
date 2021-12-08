local S = ...

eraz.register_loot("basic_food", {
	description = S("basic food"),
	type = "fixed",
	items = {
		apple = {
			name = "default:apple",
			price = 3,
			amount = 6,
		},
		bread = {
			name = "farming:bread",
			price = 1,
			amount = 1,
		},
	},
})

