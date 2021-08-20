--
-- Eraz
--

eraz = {}
eraz.loots = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

assert(loadfile(modpath .. "/settings.lua"))(modpath)
assert(loadfile(modpath .. "/api.lua"))(S)
assert(loadfile(modpath .. "/loots.lua"))(S)
assert(loadfile(modpath .. "/brain_merchant.lua"))()
assert(loadfile(modpath .. "/merchant.lua"))(S)
assert(loadfile(modpath .. "/cloth.lua"))(S)
if eraz.settings.spawn then
	assert(loadfile(modpath .. "/spawn.lua"))(S)
end
local user_file = modpath .. "/user.lua"
if eraz.file_exists(user_file) then
	assert(loadfile(user_file))()
end
