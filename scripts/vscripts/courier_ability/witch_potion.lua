require("lib/bmd_timers")
function WitchPotion( event )
	local caster = event.caster
	local ability = event.ability
	local center = caster:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor("potion_create_range", (ability:GetLevel() - 1))
	local frog_number=0
	enemies = FindUnitsInRadius(caster:GetTeam(), center, nil, radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER, false)
	for _,unit in pairs(enemies) do
		if unit:HasModifier("modifier_voodoo_datadriven") then
			frog_number=frog_number+1
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", PATTACH_CUSTOMORIGIN, unit)
	        ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
	        ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	        Timers:CreateTimer({
   	              endTime = 2,
			      callback =function()
				   ParticleManager:DestroyParticle(particle,false)
				return nil
			end})
		end
	end
	friends=FindUnitsInRadius(caster:GetTeam(), center, nil, radius, 
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER, false)
	for _,unit in pairs(friends) do
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", PATTACH_CUSTOMORIGIN, unit)
	    ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
	    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	    Timers:CreateTimer({
   	              endTime = 2,
			      callback =function()
				   ParticleManager:DestroyParticle(particle,false)
				return nil
			end})
		frog_number=frog_number+1
	end
	local have_inventory_flag=0
    for i = 0,5 do
		local item = caster:GetItemInSlot(i)
		if item == nil then
			have_inventory_flag=1
		end
	end
	for i=1,frog_number do 
	  if have_inventory_flag == 1 then
		caster:AddItem(CreateItem("item_witch_potion", nil, nil))
	  else 
        CreateItemOnPositionSync(caster:GetOrigin(), CreateItem("item_witch_potion", nil, nil))
	  end
	end
end