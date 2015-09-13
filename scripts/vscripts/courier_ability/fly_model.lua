

function Transform( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	local modifier_one = keys.modifier_one
	-- Deciding the transformation level
	local modifier=modifier_one
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
end

--[[Author: Pizzalol/Noya
	Date: 12.01.2015.
	Swaps the auto attack projectile and the caster model]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model =CourierRunGameMode._courierFlyModelList[caster:GetUnitName()]
	-- Saves the original model and attack capability
	if caster.caster_model == nil then
		caster.caster_model = caster:GetModelName()
	end
	-- Sets the new model and projectile
	caster:SetOriginalModel(model)
end

--[[Author: Pizzalol/Noya
	Date: 12.01.2015.
	Reverts back to the original model and attack type]]
function ModelSwapEnd( keys )
	local caster = keys.caster
	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	--[[
	local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
	local fly_origin=caster:GetAbsOrigin()
	fly_origin.z=ground_position.z
	caster:SetAbsOrigin(fly_origin)
	]]
	caster:Stop()
end
