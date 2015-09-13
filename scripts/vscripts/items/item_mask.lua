function item_mask_datadriven_recalculate_charge_bonuses(keys)
	local total_charge_count = 0

	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
		print ("item_name"..current_item:GetName())
	    end
		if current_item ~= nil and current_item:GetName() == "item_sobi_mask_datadriven" then
			total_charge_count = total_charge_count + current_item:GetCurrentCharges()
		end
	end
    print ("total charge"..total_charge_count)
	--Temporarily remove all existing Bloodstone charge modifiers on the unit.
	while keys.caster:HasModifier("modifier_item_mask_datadriven_charge") do
		keys.caster:RemoveModifierByName("modifier_item_mask_datadriven_charge")
	end
	
	--Apply modifiers giving the player bonus mana regen and less gold lost on death.
	for i=1, total_charge_count, 1 do
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_mask_datadriven_charge", nil)
	end
end
function item_mask_datadriven_remove_charges(keys)	
	while keys.caster:HasModifier("modifier_item_mask_datadriven_charge") do
		keys.caster:RemoveModifierByName("modifier_item_mask_datadriven_charge")
	end
end