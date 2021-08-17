local S = ...

--Adventurer Jacket

player_api.register_cloth("eraz:adventurer_jacket", {
	description = S("Adventurer Jacket"),
	texture = "eraz_adventurer_jacket.png",
	inventory_image = "eraz_adventurer_jacket_inv.png",
	wield_image = "eraz_adventurer_jacket_inv.png",
	preview = "eraz_adventurer_jacket_preview.png",
	gender = "unisex",
	groups = {cloth = 2},
})

--Adventurer Boots

player_api.register_cloth("eraz:adventurer_boots", {
	description = S("Adventurer Boots"),
	texture = "eraz_adventurer_boots.png",
	inventory_image = "eraz_adventurer_boots_inv.png",
	wield_image = "eraz_adventurer_boots_inv.png",
	preview = "eraz_adventurer_boots_preview.png",
	gender = "unisex",
	groups = {cloth = 4},
})
