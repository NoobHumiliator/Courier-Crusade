

function check_load( keys )
	local caster = keys.caster
	local rated_load=caster.rated_load
	local ability = keys.ability
	local all_item_weight=0
  local base_speed=caster:GetBaseMoveSpeed()
	local modifier_view=keys.modifier_view
	local modifier_slow=keys.modifier_slow
  local modifier_root=keys.modifier_root
  local modifier_weight_stack=keys.modifier_weight_stack
  local modifier_heal=keys.modifier_regen_datadriven
  local modifier_strength=keys.modifier_strength_counter
  local modifier_agility=keys.modifier_agility_counter
  local modifier_intellect=keys.modifier_intellect_counter
  local modifier_damage=keys.modifier_damage_counter
  local modifier_speed=keys.modifier_speed_counter
  local modifier_armor=keys.modifier_armor_counter
	for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop        	
        local Item = caster:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
           if Item ~= nil and Item:GetName() then -- makes sure that the item exists and making sure it is the correct item
               if Item:IsPermanent() then
               		if CourierRunGameMode._itemweightList[Item:GetName()]~=nil then
                          all_item_weight=all_item_weight+CourierRunGameMode._itemweightList[Item:GetName()]
                      end
               else
                    local times=Item:GetCurrentCharges()
                    if CourierRunGameMode._itemweightList[Item:GetName()]~=nil then
                      all_item_weight=all_item_weight+CourierRunGameMode._itemweightList[Item:GetName()]*times
                    end
               end
           end    
    end
   if all_item_weight>0 then
       if not caster:HasModifier(modifier_weight_stack) then
       ability:ApplyDataDrivenModifier(caster, caster, modifier_weight_stack, {})
       end
       caster:SetModifierStackCount(modifier_weight_stack, ability, all_item_weight)
    end
    if  all_item_weight==0 then
     caster:RemoveModifierByName(modifier_weight_stack)
    end  

    local over_weight=0
    over_weight=all_item_weight-rated_load
    if over_weight>0 then
      if over_weight>=rated_load*4 then 
        ability:ApplyDataDrivenModifier(caster, caster, modifier_root, {})
      else
       caster:RemoveModifierByName(modifier_root)
       ability:ApplyDataDrivenModifier(caster, caster, modifier_view, {})
       if not caster:HasModifier(modifier_slow) then
         ability:ApplyDataDrivenModifier(caster, caster, modifier_slow, {})
       end
       caster:SetModifierStackCount(modifier_slow, ability, (over_weight/(rated_load*4))*base_speed)
       ability:ApplyDataDrivenModifier(caster, caster, modifier_view, {})
      end
    else
       caster:RemoveModifierByName(modifier_root)
       caster:RemoveModifierByName(modifier_view)
       caster:RemoveModifierByName(modifier_slow)
    end
    local bonehero=nil
    local player_id=caster:GetContext("owner_id")
    local player=PlayerResource:GetPlayer(player_id)
     if player:GetTeam()==DOTA_TEAM_GOODGUYS then
       bonehero=CourierRunGameMode._good_hero_handle
     elseif player:GetTeam()==DOTA_TEAM_BADGUYS then
       bonehero=CourierRunGameMode._bad_hero_handle
     end
    local success_send_one_piece=false 
    if bonehero then
      local to_hero_distance = ( caster:GetOrigin() - bonehero:GetOrigin() ):Length()
      if to_hero_distance<200 then
        for itemSlotNumber = 0, 5, 1 do 
            local Item_check_for_destory = caster:GetItemInSlot( itemSlotNumber )
             if Item_check_for_destory ~= nil and Item_check_for_destory:GetName() and Item_check_for_destory:GetName()~="item_inventory_blocker" and CourierRunGameMode._itemweightList[Item_check_for_destory:GetName()]~=nil then
                success_send_one_piece=true
                if Item_check_for_destory:IsPermanent() then
                  local strength_add=CourierRunGameMode._itemStrengthList[Item_check_for_destory:GetName()]
                  if bonehero:HasModifier(modifier_strength) then
                   local strength_stack_count = bonehero:GetModifierStackCount(modifier_strength, ability)
                   bonehero:SetModifierStackCount(modifier_strength, ability, strength_stack_count + strength_add)
                  elseif strength_add>0 then
                   ability:ApplyDataDrivenModifier(caster, bonehero, modifier_strength, {})
                   bonehero:SetModifierStackCount(modifier_strength, ability, strength_add)
                   else
                  end
                  local agility_add=CourierRunGameMode._itemAgilityList[Item_check_for_destory:GetName()]
                  if bonehero:HasModifier(modifier_agility) then
                      local agility_stack_count = bonehero:GetModifierStackCount(modifier_agility, ability)
                      bonehero:SetModifierStackCount(modifier_agility, ability, agility_stack_count + agility_add)
                   elseif agility_add>0 then
                      ability:ApplyDataDrivenModifier(caster, bonehero, modifier_agility, {})
                      bonehero:SetModifierStackCount(modifier_agility, ability, agility_add)
                  end
                  local intellect_add=CourierRunGameMode._itemIntellectList[Item_check_for_destory:GetName()]
                  if bonehero:HasModifier(modifier_intellect) then
                     local intellect_stack_count = bonehero:GetModifierStackCount(modifier_intellect, ability)
                     bonehero:SetModifierStackCount(modifier_intellect, ability, intellect_stack_count + intellect_add)
                  elseif intellect_add>0 then
                      ability:ApplyDataDrivenModifier(caster, bonehero, modifier_intellect, {})
                      bonehero:SetModifierStackCount(modifier_intellect, ability, intellect_add)
                  end
                  local damage_add=CourierRunGameMode._itemDamageList[Item_check_for_destory:GetName()]
                   if bonehero:HasModifier(modifier_damage) then
                      local damage_stack_count = bonehero:GetModifierStackCount(modifier_damage, ability)
                       bonehero:SetModifierStackCount(modifier_damage, ability, damage_stack_count + damage_add)
                   elseif damage_add>0 then
                      ability:ApplyDataDrivenModifier(caster, bonehero, modifier_damage, {})
                      bonehero:SetModifierStackCount(modifier_damage, ability, damage_add)
                   end
                  local speed_add=CourierRunGameMode._itemSpeedList[Item_check_for_destory:GetName()] 
                   if bonehero:HasModifier(modifier_speed) then
                       local speed_stack_count = bonehero:GetModifierStackCount(modifier_speed, ability)
                       bonehero:SetModifierStackCount(modifier_speed, ability, speed_stack_count + speed_add)
                   elseif speed_add>0 then
                      ability:ApplyDataDrivenModifier(caster, bonehero, modifier_speed, {})
                      bonehero:SetModifierStackCount(modifier_intellect, ability, speed_add)
                   end
                  local armor_add=CourierRunGameMode._itemArmorList[Item_check_for_destory:GetName()]
                   if bonehero:HasModifier(modifier_armor) then
                     local armor_stack_count = bonehero:GetModifierStackCount(modifier_armor, ability)
                     bonehero:SetModifierStackCount(modifier_armor, ability, armor_stack_count + armor_add)
                   elseif armor_add>0  then 
                      ability:ApplyDataDrivenModifier(caster, bonehero, modifier_armor, {})
                      bonehero:SetModifierStackCount(modifier_armor, ability, armor_add)
                   end   
                else
                local times=Item_check_for_destory:GetCurrentCharges()
                times=times*CourierRunGameMode._itemHealList[Item_check_for_destory:GetName()]
                   for i = 1, times do
                     ability:ApplyDataDrivenModifier(caster, bonehero, modifier_heal, {})
                   end
               end
                if Item_check_for_destory:GetName()~="item_inventory_blocker" and CourierRunGameMode._itemweightList[Item_check_for_destory:GetName()]~=nil then
                caster:RemoveItem(Item_check_for_destory)
                end
             end
         end
      end 
    end
    if success_send_one_piece then
      if player:GetTeam()==DOTA_TEAM_GOODGUYS then
          local particle_1= ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf",PATTACH_ABSORIGIN,bonehero)
          StartSoundEvent( "Hero_Sven.WarCry", caster)
          bonehero:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
      elseif player:GetTeam()==DOTA_TEAM_BADGUYS then
          local particle_2= ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf",PATTACH_ABSORIGIN,bonehero)
          StartSoundEvent( "Hero_Axe.Culling_Blade_Success", caster)
          bonehero:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
      end
      if caster.rated_load then
        caster.rated_load=caster.rated_load+math.floor(all_item_weight*0.3)
        local mana=caster:GetMana()
        caster:CreatureLevelUp(math.floor(all_item_weight*0.3))
        local player_id_reward=caster:GetContext("owner_id")
        local player_reward=PlayerResource:GetPlayer(player_id_reward)
        player_reward:GetAssignedHero():ModifyGold(math.floor(all_item_weight)*50, false, 0)
        caster:SetMana(mana)
        local particle= ParticleManager:CreateParticle("particles/dire_fx/bad_stuff_end_sparks.vpcf",PATTACH_ABSORIGIN,caster)
        AMHC:CreateNumberEffect(caster,math.floor(all_item_weight*0.3),3,AMHC.MSG_EVADE,"yellow",0)
      end
    end
end
