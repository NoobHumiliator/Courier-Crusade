require("lib/bmd_timers")

function KnightCleave(keys)

	local caster = keys.caster

	-- Calculate center
	local center = caster:GetAbsOrigin() + RotatePosition(Vector(0,0,0), VectorToAngles(
		caster:GetForwardVector()), Vector(160 + caster:GetPaddedCollisionRadius(),0,0))
	
	target = FindUnitsInRadius(caster:GetTeam(), center, nil, 160, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER, false)
		
	for i,unit in pairs(target) do
	
		ApplyDamage({
			victim = unit,
			attacker = caster,
			damage = 20,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
		
		EmitSoundOn("Hero_Sven.Attack.Ring", unit)
		EmitSoundOn("Hero_Sven.Attack.Impact", unit)
		
	end
	Timers:CreateTimer({
   	              endTime = 0.22,
			      callback = function()
   	              for i,unit in pairs(target) do
	  	             ApplyDamage({
			         victim = unit,
			         attacker = caster,
			         damage = 20,
			         damage_type = DAMAGE_TYPE_MAGICAL
		             })		
		             EmitSoundOn("Hero_Sven.Attack.Ring", unit)
		             EmitSoundOn("Hero_Sven.Attack.Impact", unit)		
	              end
				return nil
			end})


end
