local S = ...

--SPAWN

eraz.spawn = function(spawn_pos, limit_max_mobs, abr, liquidflag)
	if minetest.is_protected(spawn_pos, "") then
		return
	end
	local ent = minetest.add_entity(spawn_pos, "eraz:merchant")
	local ent_ref = ent:get_luaentity()
	ent_ref.spawned = mobkit.remember(ent_ref, "spawned", true)
	ent_ref.lifetime = mobkit.remember(ent_ref, "lifetime", eraz.settings.lifetime)
	ent_ref.loot = mobkit.remember(ent_ref, "loot", eraz.set_loot())
	local loot_description = eraz.loots[ent_ref.loot].description or S("unknown stuff")
	if eraz.settings.spawn_announce then
		minetest.chat_send_all(S("A new merchant has just arrived at")
			.." ("..tostring(math.round(spawn_pos.x))..", "..tostring(math.round(spawn_pos.z))
			.."),".." "..S("bringing").." "..loot_description
		)
	end
end

minetest.register_globalstep(function(dtime)
	local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 3
	local radius =  abr * 16 --recommended
	local interval = eraz.settings.spawn_interval
	local spawn_pos, liquidflag = mobkit.get_spawn_pos_abr(dtime, interval, radius, eraz.settings.spawn_chance, 0.2)
	if spawn_pos and not(liquidflag) then
		eraz.spawn(spawn_pos, true, abr, liquidflag)
	end
end)

eraz.lifetime = function(self)
	if mobkit.timer(self, 1) then
		if self.lifetime > 0 then
			self.lifetime = mobkit.remember(self, "lifetime", (self.lifetime - 1))
		elseif (self.lifetime <= 0) and not(self.trading) then
			self.object:remove()
		end
	end
end
