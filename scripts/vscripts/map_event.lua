function random_courier_for_player(trigger)
 
     -- 使用FindByName来获取要传送的位置
    if  trigger.activator:FindAbilityByName("change_courier_cooldown") then
      if trigger.activator:FindAbilityByName("change_courier_cooldown"):IsCooldownReady() then
        --[[
        if trigger.activator:IsHero() then --如果是英雄触发的
          local hero=trigger.activator
          local player=PlayerResource:GetPlayer(hero:GetMainControllingPlayer())
          local hero_position=player:GetAssignedHero():GetAbsOrigin()
          hero:Stop()           
          hero:SetControllableByPlayer(-1, true)
          hero:SetAbilityPoints(0)
          hero:AddAbility("ability_dummy")
          hero:FindAbilityByName("ability_dummy"):SetLevel(1)
          hero:SetDayTimeVisionRange(0)
          hero:SetNightTimeVisionRange(0)
          player:GetAssignedHero():SetAbsOrigin(hero_position- Vector(0,0,1000)) --英雄埋到地下
          local cooldown_ability=trigger.activator:FindAbilityByName("change_courier_cooldown")
          if    cooldown_ability then
                cooldown_ability:StartCooldown(2000.0)
          end
          local rand_number= RandomInt(1,#CourierRunGameMode._courierList)
          local new_courier_name=CourierRunGameMode._courierList[rand_number]
          local slot_number=CourierRunGameMode._courierSlotNumberList[new_courier_name]
          PrecacheUnitByNameAsync(new_courier_name,function() end)
          local player_new_courier = SpawnUnitForPlayer(new_courier_name, player, 
          player:GetAssignedHero():GetAbsOrigin()+Vector(0,0,1000), slot_number, true, false, 80, true)
          print(new_courier_name.." 's rated load is"..CourierRunGameMode._courierRatedLoadList[new_courier_name])
          player_new_courier.rated_load=tonumber(CourierRunGameMode._courierRatedLoadList[new_courier_name])
          player_new_courier:CreatureLevelUp(player_new_courier.rated_load-1)
          local particle= ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf",PATTACH_ABSORIGIN_FOLLOW,player_new_courier)
        else
          ]]
          if trigger.activator:GetContext("owner_id") and trigger.activator.already_trigger==nil then
          local player_id=trigger.activator:GetContext("owner_id")
          trigger.activator.already_trigger=true
          print("the owner_id is"..player_id)
          local player=PlayerResource:GetPlayer(player_id)
          trigger.activator:Stop()
          trigger.activator:SetControllableByPlayer(-1, true)
          trigger.activator:RemoveModifierByName("modifier_fly_datadriven")
          trigger.activator:SetAbsOrigin(trigger.activator:GetAbsOrigin()- Vector(0,0,1000))  --沉于地下
          trigger.activator.die_in_peace=true
          trigger.activator:ForceKill(true)
          local rand_number= RandomInt(1,#CourierRunGameMode._courierList)
          local new_courier_name=CourierRunGameMode._courierList[rand_number]
           print(new_courier_name)
          local slot_number=CourierRunGameMode._courierSlotNumberList[new_courier_name]
          PrecacheUnitByNameAsync(new_courier_name,function() end)
          local player_new_courier = SpawnUnitForPlayer(new_courier_name, player, 
          player:GetAssignedHero():GetAbsOrigin()+Vector(0,0,1000),slot_number, true, false, 80, true)
          player_new_courier.rated_load=tonumber(CourierRunGameMode._courierRatedLoadList[new_courier_name])
          player_new_courier:CreatureLevelUp(player_new_courier.rated_load-1)
          local particle= ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf",PATTACH_ABSORIGIN_FOLLOW,player_new_courier)
        end
      end
    end
end