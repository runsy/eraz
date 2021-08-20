local modpath = ...

eraz.settings = {}

local settings = Settings(modpath .. "/eraz.conf")

eraz.settings.spawn = settings:get_bool("spawn") or true
eraz.settings.spawn_interval = tonumber(settings:get("spawn_interval"))
eraz.settings.spawn_chance = tonumber(settings:get("spawn_chance"))
eraz.settings.spawn_announce = settings:get_bool("spawn_announce") or true
eraz.settings.lifetime = tonumber(settings:get("lifetime"))
