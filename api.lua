local S = ...

--Helper Funtions

local function is_table_empty(_table)
    return next(_table) == nil
end

local function is_srt_empty(s)
  return s == nil or s == ''
end

local function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local function boolean_to_string(var)
	if var or var == 1 or var == "true" then
		return "true"
	elseif not(var) or var == nil or var == 0 or var == "false" then
		return "false"
	else
		return "false"
	end
end

eraz.file_exists = function(filename)
   local f = io.open(filename, "r")
   if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

--CORE functions

local function set_gender()
	local gender
	if math.random(2) == 1 then
		gender = "male"
	else
		gender = "female"
	end
	return gender
end

local function set_cloths()
	local cloths = {
		head = nil,
		upper = "eraz:adventurer_jacket",
		lower = nil,
		footwear = "eraz:adventurer_boots",
	}
	return cloths
end

local function set_loot()
	if is_table_empty(eraz.loots) then
		return nil
	end
	local keyset = {}
	for k in pairs(eraz.loots) do
		table.insert(keyset, k)
	end
	local loot = keyset[math.random(#keyset)]
	--minetest.chat_send_all(loot)
	return loot
end

local function load_loot(merchant)
	local loot = eraz.loots[merchant.loot]
	return loot
end

local function update_nick(self)
	if self.show_name and self.nick and not(self.nick == "") then
		self.object:set_nametag_attributes({
			text = self.nick,
			bgcolor = "#FFFFFF00",
		})
	else
		self.object:set_nametag_attributes({
			text = "",
		})
	end
end

local function compose_cloth(_base_texture, cloths)
	local base_texture = player_api.compose_base_texture(_base_texture, {
		canvas_size ="128x64",
		skin_texture = "player_skin.png",
		eyebrowns_pos = "16,16",
		eye_right_pos = "18,24",
		eye_left_pos = "26,24",
		mouth_pos = "16,28",
		hair_preview = false,
		hair_pos = "0,0",
	})
	local cloth = base_texture.."^".."[combine:128x64:0,0="
	if cloths.head then
		cloth = cloth..":"..player_api.cloth_pos[1].."="
			..minetest.registered_craftitems[cloths.head]._cloth_texture
	end
	if cloths.upper then
		cloth = cloth..":"..player_api.cloth_pos[2].."="
			..minetest.registered_craftitems[cloths.upper]._cloth_texture
	end
	if cloths.lower then
		cloth = cloth..":"..player_api.cloth_pos[3].."="
			..minetest.registered_craftitems[cloths.lower]._cloth_texture
	end
	if cloths.footwear then
		cloth = cloth..":"..player_api.cloth_pos[4].."="
			..minetest.registered_craftitems[cloths.footwear]._cloth_texture
	end
	return cloth
end

function eraz.set_initial_properties(self, staticdata, dtime_s)
	if dtime_s == 0 then --new merchant
		--self.type already defined when spawned
		self.nick = S("Merchant")
		self.gender = mobkit.remember(self, "gender", set_gender())
		local base_texture = player_api.create_base_texture(self.gender)
		self.base_texture = mobkit.remember(self, "base_texture", minetest.serialize(base_texture))
		local cloths = set_cloths()
		local cloth = compose_cloth(base_texture, cloths)
		self.cloth = mobkit.remember(self, "cloth", cloth)
		self.loot = mobkit.remember(self, "loot", set_loot())
		self.show_name = mobkit.remember(self, "show_name", false)
	else
		self.cloth = mobkit.recall(self, "cloth")
		self.base_texture = mobkit.recall(self, "base_texture")
		self.gender = mobkit.recall(self, "gender")
		self.loot = mobkit.recall(self, "loot")
		self.type = mobkit.recall(self, "type")
		self.nick = mobkit.recall(self, "nick") or S("Merchant")
		self.show_name = mobkit.recall(self, "show_name") or false
	end
	local model
	if self.gender == "female" then
		model = "female.b3d"
	else
		model = "character.b3d"
	end
	self.trading = mobkit.remember(self, "trading", false)
	self.object:set_properties({
		visual = "mesh",
		mesh = model,
		textures = {self.cloth},
	})
	if self.type == "fixed" then
		self:stand()
	end
	update_nick(self)
end

function eraz.register_egg(name, desc, inv_img)
	local description = S("@1", desc)
	minetest.register_craftitem(name.."_set", {
		description = description,
		inventory_image = inv_img,
		groups = {spawn_egg = 2},
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			local spawn_pos = pointed_thing.above
			local under = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end
			if spawn_pos and not minetest.is_protected(spawn_pos, placer:get_player_name()) then
				if not minetest.registered_entities[name] then
					return
				end
				local meta = itemstack:get_meta()
				local staticdata = meta:get_string("staticdata")
				local ent = minetest.add_entity(spawn_pos, name, staticdata)
				local ent_ref = ent:get_luaentity()
				local merchant_type
				local controls = placer:get_player_control()
				if controls.aux1 then
					merchant_type = "fixed"
				else
					merchant_type = "errand"
				end
				ent_ref.type = mobkit.remember(ent_ref, "type", merchant_type)
				if merchant_type == "fixed" then
					ent_ref:stand()
				end
				itemstack:take_item()
			end
		end,
	})
end

function eraz.cancel_trading(self, msg)
	local player_name = self.trading
	if player_name then
		local player = minetest.get_player_by_name(player_name)
		if player then
			minetest.close_formspec(player_name, "eraz:merchant")
			if msg then
				minetest.chat_send_player(player_name, msg)
			end
		end
	end
end

local _contexts = {}

local function get_context(name)
    local context = _contexts[name] or {}
    _contexts[name] = context
    return context
end

minetest.register_on_leaveplayer(function(player)
    _contexts[player:get_player_name()] = nil
end)

local function get_items_loot(loot)
	local items_loot = ""
	local items_count = 0
	local col = 0
	local row = 0
	local amount, price
	for item, item_def in pairs(eraz.loots[loot].items) do
		amount = tostring(item_def.amount or 1)
		price = tostring(item_def.price or 0)..elez.coin_symbol
		items_loot = items_loot..
			"item_image_button["..tostring(col)..","..tostring(row)..";1,1;"..item_def.name..";"..item..";"..amount.."/"..price.."]"
		items_count = items_count + 1
		if col == 2 then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end
	return items_loot, items_count
end

local function get_items_basket(player)
	local items_basket = ""
	local total_cost = 0
	local player_name = player:get_player_name()
	local context = get_context(player_name)
	if is_table_empty(context.basket) then
		return items_basket, total_cost
	end
	local col = 0
	local row = 0
	local amount, price
	for item, item_def in pairs(context.basket) do
		amount = tostring(item_def.amount or 1)
		price = tostring(item_def.price or 0)..elez.coin_symbol
		items_basket = items_basket..
			"item_image_button["..tostring(col)..","..tostring(row)
			..";1,1;"..item_def.name..";"..item..";"..amount.."/"..price.."]"
		total_cost = total_cost + item_def.price
		if col == 2 then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end
	context.total_cost = total_cost
	return items_basket, total_cost
end

local function compose_edit_formspec(self, player)
	local player_name = player:get_player_name()
	local context = get_context(player_name)
	local loots = ""
	local index
	local i = 1
	for loot_name in pairs(eraz.loots) do
		if i > 1 then
			loots = loots..","
		end
		loots = loots..loot_name
		if loot_name == context.merchant.loot then
			index = i
		end
		i = i + 1
	end
	if not index then
		index = 0
	end
	local selected = "false"
	if context.merchant.type == "fixed" then
		selected = "true"
	end
	local formspec = [[
		formspec_version[4]
		size[6,6]
		set_focus[btn_close;]
		field[0.5,0.5;3,0.5;ipt_nick;]]..S("Name")..":"..";"..context.merchant.nick..[[]
		checkbox[3.75,0.75;chk_show_name;]]..S("Show name")..";"..boolean_to_string(context.merchant.show_name)..[[]
		label[0.5,2;]]..S("Loot")..":"..[[]
		dropdown[1.5,1.5;3;drpdwn;]]..loots..[[;]]..tostring(index)..[[;]
		checkbox[0.5,3;chk_fixed;]]..S("Fixed")..[[;]]..selected..[[]
		style[btn_remove;bgcolor=indianred]
		button_exit[0.5,3.5;1,1;btn_remove;]]..S("Remove")..[[]
		button_exit[2.5,4.5;1,1;btn_close;]]..S("Close")..[[]
	]]
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "eraz:edit_merchant" then
        return
    end
    local player_name = player:get_player_name()
    local context = get_context(player_name)
    if fields.drpdwn then
		context.merchant.loot = mobkit.remember(context.merchant, "loot", fields.drpdwn)
	end
	if fields.chk_fixed then
		local is_fixed = minetest.is_yes(fields.chk_fixed)
		local _type
		if is_fixed then
			_type = "fixed"
		else
			_type = "errand"
		end
		context.merchant.type = mobkit.remember(context.merchant, "type", _type)
		if is_fixed then
			context.merchant:stand()
		end
	end
	if fields.ipt_nick then
		context.merchant.nick = mobkit.remember(context.merchant, "nick", fields.ipt_nick)
		update_nick(context.merchant)
	end
	if fields.chk_show_name then
		context.merchant.show_name = mobkit.remember(context.merchant, "show_name",
			minetest.is_yes(fields.chk_show_name))
		update_nick(context.merchant)
	end
	if fields.btn_remove then
		if context.merchant.trading then
			minetest.close_formspec(player_name, "eraz:merchant")
		end
		eraz.cancel_trading(context.merchant, S("The merchant has been removed."))
		context.merchant.object:remove()
	end
end)

local function compose_formspec(self, player, msg)
	local money = tostring(elez.get_money(player)).." "..elez.coin_symbol
	local items_loot, items_count = get_items_loot(self.loot)
	local items_basket, total_cost = get_items_basket(player)
	total_cost = tostring(total_cost).." "..elez.coin_symbol
	local items_count_str = tostring(items_count)
	if is_srt_empty(msg) then
		msg = ""
	end
	local face = player_api.get_face(minetest.deserialize(self.base_texture), 1.0, true)
	local formspec = [[
		formspec_version[4]
		size[8.25,8.25]
		image[0.5,0.25;0.5,0.5;]]..face..[[]
		label[1.25,0.5;]]..self.nick..[[]
		label[0.5,1;]]..items_count_str.." "..S("items(s)")
			.." | "..S("Amount/Price")..[[]
		label[0.5,4.5;]]..S("Click to add to the basket")..[[]
		label[4.25,4.5;]]..S("Click to delete from the basket")..[[]
		label[5.25,0.75;]]..S("Money")..":".." "..money..[[]
		image[4.5,0.625;0.5,0.5;eraz_basket.png]
		label[5.25,1;]]..S("Cost")..":".." "..total_cost..[[]
		box[0.5,1.25;3,3;darkgray]
		scroll_container[0.5,1.25;3,3;scroll_buy;vertical;]
			]]..items_loot..[[
		scroll_container_end[]
		scrollbaroptions[min=0;max=]]..tostring(round(items_count))
			..[[;smallstep=]]..items_count_str..[[;largestep=]]..items_count_str..[[]
		style_type[scroll_buy;bgcolor=#446699]
		scrollbar[3.5,1.25;0.5,3;vertical;scroll_buy;0]
		box[4.25,1.25;3,3;darkgray]
		scroll_container[4.25,1.25;3,3;scroll_basket;vertical;]
			]]..items_basket..[[
		scroll_container_end[]
		scrollbaroptions[min=0;max=]]..tostring(round(items_count))
			..[[;smallstep=]]..items_count_str..[[;largestep=]]..items_count_str..[[]
		scrollbar[7.25,1.25;0.5,3;vertical;scroll_basket;0]
		button_exit[5.125,5;1,1;btn_buy;]]..S("Buy")..[[]
		label[0.5,6.5;]]..msg..[[]
		button_exit[3.25,6.75;1,1;btn_close;]]..S("Close")..[[]
	]]
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "eraz:merchant" then
        return
    end
    local player_name = player:get_player_name()
    local context = get_context(player_name)
    local item, item_def
    local action
    --minetest.chat_send_all(minetest.serialize(fields))
    for key, value in pairs(fields) do
		if not(key=="scroll_buy") and not(key=="scroll_basket") and not(key=="quit")
			and not(key=="btn_close") and not(key=="btn_buy") then
				item = key
				if string.sub(key, 1, 8) == "_BASKET_" then
					action = "delete"
					item_def = context.basket[item]
				else
					action = "buy"
					item_def = eraz.loots[context.merchant.loot].items[key]
				end
				break
		end
	end
	if item then
		if action == "buy" then
			item = "_BASKET_"..item
			if context.basket[item] then --already in the basket=>only increase amount
				context.basket[item].amount = context.basket[item].amount + item_def.amount
				context.basket[item].price = context.basket[item].price + item_def.price
			else --new
				context.basket[item] = {
					name = item_def.name,
					price = item_def.price,
					amount = item_def.amount,
				}
			end
		else --action = "delete"
			context.total_cost = context.total_cost - context.basket[item].price
			context.basket[item] = nil
		end
		minetest.show_formspec(player_name, "eraz:merchant",
			compose_formspec(context.merchant, player))
		return
	end
	if fields.btn_buy then
		local msg
		if context.total_cost <= 0 then
			msg = S("You have not selected products to buy!")
		elseif elez.get_money(player) < context.total_cost then
			msg = S("You have not enough money!")
		else
			local inv = player:get_inventory()
			local item_stack
			local cost = 0
			for _item, _item_def in pairs(context.basket) do
				item_stack = ItemStack(_item_def.name.." "..tostring(_item_def.amount))
				if inv:room_for_item("main", item_stack) then
					inv:add_item("main", item_stack)
					context.basket[_item] = nil
					elez.add_money(player, -_item_def.price)
					cost = cost + _item_def.price
					context.total_cost = context.total_cost - _item_def.price
				end
			end
			msg = S("You have purchased products with a value of").." "
				..tostring(cost).." "..elez.coin_symbol
		end
		minetest.show_formspec(player_name, "eraz:merchant",
			compose_formspec(context.merchant, player, msg))
		return
	end
	context.merchant.trading = false
end)

local function load_shop(self, player)
	local player_name = player:get_player_name()
	local loot = load_loot(self)
	if not loot then
		minetest.chat_send_player(player_name, S("This merchant has not loot."))
		return
	end
	local context = get_context(player_name)
	context.merchant = self
	context.basket = {}
	context.total_cost = 0
	minetest.show_formspec(player_name, "eraz:merchant",
		compose_formspec(self, player))
	self.trading = player_name
	if self.type == "errand" then
		self:stand() --stop merchant
	end
end

local function edit_merchant(self, player)
	local player_name = player:get_player_name()
	local context = get_context(player_name)
	context.merchant = self
	minetest.show_formspec(player_name, "eraz:edit_merchant",
		compose_edit_formspec(self, player))
end

function eraz.register_loot(name, def)
	if not eraz.loots[name] then
		eraz.loots[name] = def
	end
end

function eraz.on_rightclick(self, player)
	local controls = player:get_player_control()
	local has = minetest.check_player_privs(player,  {
		server = true,
	})
	if has and controls.aux1 then
		edit_merchant(self, player)
		return
	end
	if self.trading then
		minetest.chat_send_player(player:get_player_name(), S("This merchant is already trading with another player."))
		return
	else
		load_shop(self, player)
		return
	end
end
