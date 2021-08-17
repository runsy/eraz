--
-- ERRAND MERCHANTS
--
local S = ...

minetest.register_entity("eraz:merchant",{
	type = "errand",
	genre = "male",
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"character.png"},
	visual_size = {x= 1.0, y= 1.0},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	static_save = true,
	physical = true,
	collide_with_objects = true,
	-- mod props

	-- mobkit api props
	get_staticdata = mobkit.statfunc,
	stepheight = 0.1, --EVIL!
	springiness = 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 3,
	jump_height = 1,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 20,

	attack = {range=0.5, damage_groups = {fleshy=3}},

	animation = {
		stand = {range= { x= 0, y= 79}, speed= 5, loop= true},
		walk = {range= { x= 168, y= 187}, speed= 25, loop= true},
	},

	logic = eraz.merchant_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		eraz.set_initial_properties(self, staticdata, dtime_s)
	end,

	on_step = function(self, dtime)
		mobkit.stepfunc(self, dtime) -- required
	end,

	on_rightclick = function(self, clicker)
		eraz.on_rightclick(self, clicker)
	end,

	stand = function(self)
		mobkit.clear_queue_low(self)
		mobkit.clear_queue_high(self)
		mobkit.animate(self, "stand")
	end,

	on_die = function(self)
		eraz.cancel_trading(self, S("The merchant has died."))
	end,

})

eraz.register_egg("eraz:merchant", S("Merchant"), "eraz_spawnegg_merchant.png", false)
