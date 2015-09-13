function ArcaneOrb( keys )
	local ability = keys.ability
	local caster = keys.caster
	local mana = caster:GetMana()
	local target = keys.target
	local intellect=caster:GetIntellect()
	local summon_damage = ability:GetLevelSpecialValueFor("illusion_damage", (ability:GetLevel() -1))
	local extra_damage = ability:GetLevelSpecialValueFor("mana_pool_damage_pct", (ability:GetLevel() -1)) / 100
	local damage_table = {}
    if intellect>9 then
    local particle= ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf",PATTACH_ABSORIGIN,target)
    ParticleManager:SetParticleControl(particle, 1, Vector( intellect-9,intellect-9, 0))
    StartSoundEvent( "Hero_ObsidianDestroyer.ArcaneOrb.Impact", target)
    end
	damage_table.attacker = caster
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.victim = target


	if not target:IsRealHero() or target:IsSummoned() then
		damage_table.damage = mana * extra_damage + summon_damage
	else
		damage_table.damage = mana * extra_damage
	end 

	ApplyDamage(damage_table)
end