local modpath = ...

local settings = Settings(modpath .. "/eraz.conf")

eraz.settings = {
	spawn = settings:get_bool("spawn") or true,
	spawn_interval = tonumber(settings:get("spawn_interval")),
	spawn_chance = tonumber(settings:get("spawn_chance")),
	spawn_announce = settings:get_bool("spawn_announce") or true,
	lifetime = tonumber(settings:get("lifetime")),
}
