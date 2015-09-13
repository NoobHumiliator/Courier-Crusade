require("utilities")
require("map_event")
require("lib/bmd_timers")
require("courier_ability/fly_model")
require("courier_run_main")
require('physics')
require('barebones')
require("timers")
require("courier_ability/check_load")
require("amhc_library/amhc")
require("maze_creater")
require("tec_maze_creater")


function Activate()
	GameRules.CourierRun = CourierRunGameMode
	GameRules.CourierRun:InitGameMode()
end

function Precache( context )
	PrecacheResource( "model_folder", "models/courier", context)
	PrecacheResource( "model_folder", "models/items/courier", context)
end




