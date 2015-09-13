--[[
	Functions responsible for spawning units at random in a trigger area
	TODO: Add circular spawns, tip ent:GetFloat(keyName, defValue)
]]
function GetArea(name)

	local area_map = {}
	
	for i,v in pairs(Entities:FindAllByName(name)) do
		area_map[i] = {}

		-- Center vector
		area_map[i].center = v:GetAbsOrigin()
		
		-- Mark as not used
		area_map[i].used = false
		
		-- Size on x and y coordinates
		area_map[i].x = v:GetBoundingMaxs().x
		area_map[i].y = v:GetBoundingMaxs().y
	end

	return area_map

end

function RandomVectorInArea(area_map)

	-- Check if there are usable areas
	local all_used = true
	
	for i,area in pairs(area_map) do
		if not area.used then
			all_used = false
			break
		end
	end
	
	if all_used then
		for i,area in pairs(area_map) do
			area.used = false
		end
	end

	-- Choose random area
	local random = RandomInt(1, #area_map)
	
	while area_map[random].used do
		random = RandomInt(1, #area_map)
	end
	
	area_map[random].used = true

	-- Calculate a random offset
	local x, y
	
	x = RandomInt(-1 * area_map[random].x, area_map[random].x)
	y = RandomInt(-1 * area_map[random].y, area_map[random].y)

	return area_map[random].center + Vector(x, y, 0)

end

function IsInArea(area_map, point)

	for i,v in pairs(area_map) do
		if v.center.x - v.x <= point.x and point.x <= v.center.x + v.x and
		   v.center.y - v.y <= point.y and point.y <= v.center.y + v.y then
		   
			return true
		end
	end

	return false

end

--[[
	Functions to get all the players in the game
]]

function GetPlayers()

	local result = {}

	for i = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
		local player = PlayerResource:GetPlayer(i)
		
		if player and player:GetAssignedHero() then
			result[i] = player
		end
	end
	
	return result

end

function GetPlayerCount()

	local result = 0
	
	for i,player in pairs(GetPlayers()) do
		result = result + 1
	end
	
	return result

end

--[[
	Markers for checking elapsed time
]]

MARKER_PRECISION = 0.01

if GlobalTimeMarker == nil then
	GlobalTimeMarker = {}
end

function SetMarker(name)
		
	GlobalTimeMarker[name] = GameRules:GetGameTime()
	
end

function GetMarker(name)
 
	if GlobalTimeMarker[name] == nil then
		return 0
	end
	
	return GameRules:GetGameTime() - GlobalTimeMarker[name] + MARKER_PRECISION

end

--[[
	DIRTY HACK
	Apply a custom modifier from a bogus item
]]

function ApplyCustomModifier(unit, item_name, modifier_name, args)

	local item = CreateItem(item_name, unit, unit)
	
	if args == nil then
		args = {}
	end
	
	item:ApplyDataDrivenModifier(unit, unit, modifier_name, args)
	
	unit:RemoveItem(item)

end

--[[
	Apply player color auras
]]

function PlayerAura(unit, radius)

    local PlayerColor = {
		[0] = {255,   0,   0},
		[1]	= {  0,   0, 255},
		[2] = {  0, 255, 255},
		[3] = {128,   0, 255},
		[4] = {255, 255,   0},
		[5] = {255, 128,   0},
		[6] = { 64, 255,   0},
		[7] = {255, 128, 196},
		[8] = {  0, 128,   0},
		[9] = {255, 255, 255}
	}
	local pindex = ParticleManager:CreateParticle("particles/courierrun/" ..
		"player_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	
	local color = PlayerColor[unit:GetPlayerOwnerID()]
	
	ParticleManager:SetParticleControl(pindex, 1, Vector(color[1], color[2], color[3]))
	ParticleManager:SetParticleControl(pindex, 2, Vector(radius, 0, 0))
			
	ParticleManager:ReleaseParticleIndex(pindex)

end

--[[
 	Block a units inventory
]]

function BlockInventory(unit, leave_open)

	-- Clear the old inventory
	for i = 0,5 do
		local item = unit:GetItemInSlot(i)
		
		if item ~= nil then
			item:Destroy()
		end
	end

	-- Fill the inventory with blockers
	for i = 0,5 do
		unit:AddItem(CreateItem("item_inventory_blocker", nil, nil))
	end
	
	-- Remove part of the blockers, this way the first
	-- slots in the inventory will be free and not the last
	for i = 0,leave_open - 1 do
		unit:GetItemInSlot(i):Destroy()
	end

end

--[[
	Spawn a player controlled unit
]]

function SpawnUnitForPlayer(name, player, position, inventory, freeze, invulnerable, radius, default)

	local unit = CreateUnitByName(name, position, true, player:GetAssignedHero(), 
		player:GetAssignedHero(), player:GetTeam())

	unit:SetControllableByPlayer(player:GetPlayerID(), true)
	unit:SetContextNum("owner_id", player:GetPlayerID(), 0)   --把新分配给玩家的信使的玩家id挂载进来
	local cooldown_ability=unit:FindAbilityByName("change_courier_cooldown")
	if  cooldown_ability then
		cooldown_ability:SetLevel(1)
		cooldown_ability:StartCooldown(15.0)
	end
	--PlayerAura(unit, radius)
	BlockInventory(unit, inventory)  --删除物品栏
	
	if freeze then
		ApplyCustomModifier(unit, "item_modifier", "intro_freeze",
			{duration = "1.0"})
	end
	
	if invulnerable then
		ApplyCustomModifier(unit, "item_modifier", "invulnerable", 
			{duration = "1.0"})
	end
	
	if default then
		PlayerResource:SetOverrideSelectionEntity(player:GetPlayerID(), unit)
		
		-- DIRTY HACK
		-- Fix for centering camera
		Timers:CreateTimer({
			callback = function()
				if IsValidEntity(unit) and unit:IsAlive() then
					player:GetAssignedHero():SetAbsOrigin(unit:GetAbsOrigin() 
						- Vector(0,0,1000))			
					return 0.5
				end
			end
		})
       --[[
       GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("relocate_hero"),
       	    function() 
       	     if IsValidEntity(unit) and unit:IsAlive() then 
        	  player:GetAssignedHero():SetAbsOrigin(unit:GetAbsOrigin()- Vector(0,0,1000)) 
        	  return 0.5
        	  else return nil 
        	 end 
        	end , 0.5)
         ]]
	end
	
	return unit

end

--[[
	Play teleport sound and fire effect
	Move unit to dump spot and kill
]]

function RemoveWinner(unit, radius)

	EmitGlobalSound("Portal.Hero_Disappear")
	
	local pindex = ParticleManager:CreateParticle("particles/omniparty/teleport.vpcf",
		PATTACH_ABSORIGIN, unit)
	
	if radius == nil then
		radius = 64
	end
	
	ParticleManager:SetParticleControl(pindex, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(pindex)
	
	if IsPhysicsUnit(unit) then
		unit:StopPhysicsSimulation()
	end

	unit:SetAbsOrigin(unit:GetAbsOrigin() - Vector(0,0,512))
	unit:ForceKill(true)

end

--[[
	Kill all custom units whose name is on the list
]]

function KillUnitList(list)

	for i,unit in pairs(Entities:FindAllByName("npc_dota_creature")) do
		local u_name = unit:GetUnitName()
		
		for j,k_name in pairs(list) do
			if u_name == k_name then
				if unit:FindAbilityByName("ability_dummy") == nil and
				   unit:FindAbilityByName("ability_dummy_prop") == nil then
				   
					unit:ForceKill(true)
				else
					unit:Destroy()
				end
				
				break
			end
		end
	end

end

--[[
	Add space post padding to scoreboard elements
]]

function PostSpacePad(str, length)

	str = tostring(str)
	zero = length - string.len(str)
	
	for i = 1,zero do
		str  = str .. " "
	end
	
	return str

end

--[[
	Randomly shuffle an array
]]

function ShuffleList(list)

	local result = list
	local size = #result
	
	for i = 1,size do
		local p = RandomInt(i,size)
		local aux = result[p]
		result[p] = result[i]
		result[i] = aux
	end
	
	return result

end

--[[
	Give vision of a certain area to a player
]]

WARD_GROUND = 0
WARD_AIR = 1

function CreateWard(type, position, player, range, truesight)

	if type == WARD_GROUND then
		type = "npc_ward_ground"
	elseif type == WARD_AIR then
		type = "npc_ward_air"
	end

	local ward = CreateUnitByName(type, position, false, player:GetAssignedHero(),
		player:GetAssignedHero(), player:GetTeam())
	
	if range then
		ward:SetDayTimeVisionRange(range)
		ward:SetNightTimeVisionRange(range)
	end

end