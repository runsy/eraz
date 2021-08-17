--
-- Eraz
--

eraz = {}
eraz.loots = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

assert(loadfile(modpath .. "/api.lua"))(S)
assert(loadfile(modpath .. "/loots.lua"))()
assert(loadfile(modpath .. "/brain_merchant.lua"))()
assert(loadfile(modpath .. "/merchant.lua"))(S)
assert(loadfile(modpath .. "/cloth.lua"))(S)
local user_file = modpath .. "/user.lua"
if eraz.file_exists(user_file) then
	assert(loadfile(user_file))()
end
