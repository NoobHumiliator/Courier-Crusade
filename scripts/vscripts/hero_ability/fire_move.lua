MOVE_SPEED=5
function Fire_move( keys )
	local ability = keys.ability
	local caster = keys.caster
	local corner_bottom_left = Entities:FindByName(nil, "MAZE_corner_bottom_left"):GetAbsOrigin()
  local coner_top_right=Entities:FindByName(nil, "MAZE_corner_top_right"):GetAbsOrigin()
  local t=0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("fire_move"), 
                function( )                      
                 local caster_abs = caster:GetAbsOrigin() 
                   if (caster_abs.x - corner_bottom_left.x)>10 then                  
                  caster:SetAbsOrigin(caster_abs - Vector(MOVE_SPEED,0,0))
                  if t==0 then
                    local projectile_information =  
                    {
                    EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
                    Ability = ability,
                    vSpawnOrigin = caster:GetAbsOrigin(),
                    fDistance = MOVE_SPEED*10*12,
                    fStartRadius = 0,
                    fEndRadius = 0,
                    Source = caster,
                    bHasFrontalCone = false,
                    iMoveSpeed = MOVE_SPEED*10,
                    bReplaceExisting = false,
                    bProvidesVision = false,
                    iVisionTeamNumber = DOTA_TEAM_GOODGUYS,
                    iVisionRadius = 50,
                    bDrawsOnMinimap = false,
                    bVisibleToEnemies = true, 
                    bDeleteOnHit = false,
                    iUnitTargetTeam = DOTA_TEAM_NOTEAM,
                    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                    iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
                    fExpireTime = GameRules:GetGameTime() + 12,
                    }
                    projectile_information.vVelocity = Vector(MOVE_SPEED*-10,0,0)
                    local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)
                    t=120
                  else
                    t=t-1
                   end
                   return 0.1
                   else
                   caster:RemoveSelf()              
                   return nil
                  end
                end, 0)
  --[[
  GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("fire_move_particles"), 
                function( )                      
                 local projectile_information =  
                    {
                    EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
                    Ability = ability,
                   vSpawnOrigin = caster:GetAbsOrigin(),
                   fDistance = coner_top_right.x-corner_bottom_left.x+1050,
                   fStartRadius = 0,
                   fEndRadius = 0,
                   Source = caster,
                   bHasFrontalCone = false,
                   iMoveSpeed = MOVE_SPEED*100,
                   bReplaceExisting = false,
                   bProvidesVision = false,
                   iVisionTeamNumber = DOTA_TEAM_GOODGUYS,
                   iVisionRadius = 50,
                   bDrawsOnMinimap = false,
                   bVisibleToEnemies = true, 
                   iUnitTargetTeam = DOTA_TEAM_GOODGUYS,
                   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                   iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
                   fExpireTime = GameRules:GetGameTime() + (coner_top_right.x-corner_bottom_left.x)/(MOVE_SPEED*3.5),
                   }
                   projectile_information.vVelocity = Vector(MOVE_SPEED*-5,0,0)
                   local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)
                   return nil
                end, 0)
  GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("fire_move_particles_2"), 
                function( )                      
                 local projectile_information =  
                    {
                    EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
                    Ability = ability,
                   vSpawnOrigin = caster:GetAbsOrigin(),
                   fDistance = coner_top_right.x-corner_bottom_left.x+1050,
                   fStartRadius = 0,
                   fEndRadius = 0,
                   Source = caster,
                   bHasFrontalCone = false,
                   iMoveSpeed = MOVE_SPEED*100,
                   bReplaceExisting = false,
                   bProvidesVision = false,
                   iVisionTeamNumber = DOTA_TEAM_BADGUYS,
                   iVisionRadius = 50,
                   bDrawsOnMinimap = false,
                   bVisibleToEnemies = true, 
                   iUnitTargetTeam = DOTA_TEAM_BADGUYS,
                   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                   iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
                   fExpireTime = GameRules:GetGameTime() + (coner_top_right.x-corner_bottom_left.x)/(MOVE_SPEED*3.5),
                   }
                   projectile_information.vVelocity = Vector(MOVE_SPEED*-5,0,0)
                   local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)
                   return nil
                end, 0) 
   --]]
  
end
