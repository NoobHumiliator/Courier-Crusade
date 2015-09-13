--[[
最基本的追着人打的AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( {BehaviorNone} ) 
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end


--------------------------------------------------------------------------------------------------------
BehaviorNone = {}
function BehaviorNone:Evaluate()
	return 2 
end

function BehaviorNone:Begin()
  self.endTime = GameRules:GetGameTime() + 1
	local target=nil
	if thisEntity:GetTeamNumber()==DOTA_TEAM_BADGUYS then
      local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP, 0, 0, false)
        if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_dota_good_hero")then     
                   target=unit
               end 
           end
       end     
    elseif  thisEntity:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
       local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP, 0, 0, false)
        if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_dota_good_hero")then     
                   target=unit
               end 
           end
       end     
    end
    
	if target then 
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position =  target:GetOrigin()
		}
	else
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
	end
end

 BehaviorNone.Continue=BehaviorNone.Begin
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone}

