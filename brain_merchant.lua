-- The Brain of the Merchant
--

function eraz.merchant_brain(self)

	--local pos = self.object:get_pos()

	mobkit.vitals(self)

	if self.hp <= 0 then
		self:on_die()
		return
	end

	if mobkit.timer(self, 1) then

		local prty = mobkit.get_queue_priority(self)

		if prty < 30 then
			if self.isinliquid then
				mobkit.hq_liquid_recovery(self, 30)
				return
			end
		end

		--local player = mobkit.get_nearby_player(self)

		--minetest.chat_send_all("test")

		--Wandering default
		if mobkit.is_queue_empty_high(self) and self.type == "errand"
			and not(self.trading) then
			mobkit.hq_roam(self, 0)
		end

	end
end
