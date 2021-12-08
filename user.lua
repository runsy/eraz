local S = ...

eraz.register_loot("minerals", {
	description = S("some minerals"),
	type = "fixed",
	items = {
		iron = {
			name = "default:iron_lump",
			price = 10,
			amount = 25,
		},
		copper = {
			name = "default:copper_lump",
			price = 5,
			amount = 25,
		},
		bauxite = {
			name = "aloz:bauxite_lump",
			price = 7,
			amount = 25,
		},
	},
})

eraz.register_loot("fruits", {
	description = S("some fruits"),
	type = "fixed",
	items = {
		apple = {
			name = "default:apple",
			price = 3,
			amount = 6,
		},
		cherries = {
			name = "cherrytree:cherries",
			price = 5,
			amount = 10,
		},
		lemon = {
			name = "lemontree:lemon",
			price = 2,
			amount = 12,
		},
		clementine = {
			name = "clementinetree:clementine",
			price = 4,
			amount = 8,
		},
		blueberries = {
			name = "default:blueberries",
			price = 5,
			amount = 15,
		},
		pineapple = {
			name = "pineapple:pineapple",
			price = 6,
			amount = 4,
		},
		pomegranate = {
			name = "pomegranate:pomegranate",
			price = 3,
			amount = 7,
		},
		plum= {
			name = "plumtree:plum",
			price = 2,
			amount = 8,
		},
		cacao_beans = {
			name = "cacaotree:cacao_beans",
			price = 10,
			amount = 30,
		},
		barberries = {
			name = "swaz:barberries",
			price = 1,
			amount = 20,
		},
		redcurrants = {
			name = "redw:redcurrants",
			price = 1,
			amount = 15,
		},
		acorn = {
			name = "oak:acorn",
			price = 2,
			amount = 25,
		},
		chestnut = {
			name = "chestnuttree:fruit",
			price = 3,
			amount = 25,
		},
		persimmon = {
			name = "ebony:persimmon",
			price = 5,
			amount = 7,
		},
	},
})

