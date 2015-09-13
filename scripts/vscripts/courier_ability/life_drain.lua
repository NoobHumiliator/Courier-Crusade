--[[
	Author: Noya
	Date: April 5, 2015
	Creates the Life Drain Particle rope. 
	It is indexed on the caster handle to have access to it later, because the Color CP changes if the drain is restoring mana.
]]
function LifeDrainParticle( event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
	caster.LifeDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.LifeDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

end

--[[
	Author: Noya
	Date: April 5, 2015
	When cast on an enemy, drains health from the target enemy unit to heal himself. 
	If the hero has full HP, and the enemy target is a Hero, Life Drain will restore mana instead.
	When cast on an ally, it will drain his own health into his ally.
]]
function LifeDrainHealthTransfer( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local health_drain = ability:GetLevelSpecialValueFor( "health_drain" , ability:GetLevel() - 1 )
	local tick_rate = ability:GetLevelSpecialValueFor( "tick_rate" , ability:GetLevel() - 1 )
	local HP_drain = health_drain * tick_rate
	-- Act according to the targets team
		-- Location variables
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()

	-- Distance variables
	local distance = (target_location - caster_location):Length2D()
	local break_distance = ability:GetCastRange()
	local direction = (target_location - caster_location):Normalized()

		-- If the leash is broken then stop the channel
	 if distance >= break_distance then
		target:RemoveModifierByName( "modifier_life_drain" )
	 end
	 if target.rated_load~=nil then
	 	if target.rated_load>50 then
	 		  local caster_mana=caster:GetMana()
	 		  local caster_health=caster:GetHealth()
	 		  local target_mana=target:GetMana()
	 		  local target_health=target:GetHealth()
	 	      caster.rated_load=caster.rated_load+math.floor(target.rated_load*0.02)
	 	      caster:CreatureLevelUp(math.floor(target.rated_load*0.02))
	 	      target.rated_load=target.rated_load-math.floor(target.rated_load*0.02)
	 	      target:CreatureLevelUp(-math.floor(target.rated_load*0.02))
	 	      caster:SetMana(caster_mana)
	 	      caster:SetHealth(caster_health)
	 	      target:SetMana(target_mana)
	 	      target:SetHealth(target_health)
	    end
	 end 
end

function LifeDrainParticleEnd( event )
	local caster = event.caster
	ParticleManager:DestroyParticle(caster.LifeDrainParticle,false)
end