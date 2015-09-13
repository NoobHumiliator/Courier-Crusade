require("maze_creater")


if TecMazeCreater == nil then
	TecMazeCreater = class({})
end

TEC_MAZE_WALL_SIZE = 160

function TecMazeCreater:Init()

	-- Find the environment parameters of the MAZE
	self._corner_bottom_left = Entities:FindByName(nil, "tec_corner_bottom_left"):GetAbsOrigin()
	self._corner_top_right = Entities:FindByName(nil, "tec_corner_top_right"):GetAbsOrigin()
    self._skip_hole={}
	local size = self._corner_top_right - self._corner_bottom_left
	local w = math.floor(math.abs(size.x) / TEC_MAZE_WALL_SIZE) + 1
	local h = math.floor(math.abs(size.y) / TEC_MAZE_WALL_SIZE) + 1
	
	if w % 2 == 0 then w = w - 1 end
	if h % 2 == 0 then h = h - 1 end

	-- Generate a random MAZE
	local MAZE = {}
	self.bombs={}
	
	-- Initialize a empty grid
	for i = 1,w do
		MAZE[i] = {}
		self.bombs[i] = {}
		for j = 1,h do
			if i==1 or i==w then
			MAZE[i][j] = {block = 1}
		    elseif j==1 or j==h then
		    MAZE[i][j] = {block = 1}
            else
            MAZE[i][j] = {block = 0}	
			end	
		end
	end
	

	-- Make walls with  recursion
	self._tr={x=w-1,y=h-1}
	self._bl={x=2,y=2}
	self:REC(MAZE,self._tr,self._bl)
	
 
	-- Make the MAZE accessible from the outside
	MAZE[1][6].block = 0
	MAZE[2][6].block = 0
	MAZE[w][math.floor(h/2)].block = 0
	MAZE[w-1][math.floor(h/2)].block = 0
    

    for _,i in pairs(self._skip_hole) do
    	MAZE[i.x][i.y].block=0
    end
    	


	for i = 1,w do
		for j = 1,h do
			local position = self:GetPosition(i, j)
			local block = MAZE[i][j].block		
			if block==1 then
				local name = "npc_maze_" .. ((block == 1) and "wall_tec" or "guard")
				local wall = CreateUnitByName(name, position,false, nil, nil, DOTA_TEAM_NEUTRALS)
				wall:SetHullRadius(TEC_MAZE_WALL_SIZE / 2 + 2)
			end
		end
	end	
   self.maze=MAZE
   self.w=w
   self.h=h
   Timers:CreateTimer({
			endTime = 1,
			callback = function()
			    local coordinate=TecMazeCreater:FindClearPlaceforBomb(w,h)
				local bomb = CreateUnitByName('bomber_bomb', TecMazeCreater:GetPosition(coordinate.x,coordinate.y), true, nil, nil, DOTA_TEAM_NEUTRALS)
				bomb.x=coordinate.x
				bomb.y=coordinate.y
                TecMazeCreater.bombs[coordinate.x][coordinate.y] = bomb
				return 0.4
			end
		})
   Timers:CreateTimer({
			endTime = 1,
			callback = function()
			    local coordinate=TecMazeCreater:FindClearPlaceforBomb(w,h)
				local stasis_trap = CreateUnitByName('stasis_trap', TecMazeCreater:GetPosition(coordinate.x,coordinate.y), true, nil, nil, DOTA_TEAM_NEUTRALS)
				return 1
			end
		})
   Timers:CreateTimer({
   	              endTime = 10,
			      callback = function()
   	              local rune=nil 
				  local rune_coordinate=TecMazeCreater:FindClearPlaceforBomb(w,h)
                  local position=TecMazeCreater:GetPosition(rune_coordinate.x,rune_coordinate.y)
                  local c = RandomInt(1,789)
	              if c >= 1 and c <250 then
		          rune = CreateUnitByName('maze_haste_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
	              elseif c >= 250 and c <500 then
		          rune = CreateUnitByName('maze_power_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)      
		          elseif c >= 500 and c <750 then
		          rune = CreateUnitByName('maze_regeneration_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
		          elseif c >= 750 and c <790 then
		          rune = CreateUnitByName('maze_useful_item_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
                  end
                  rune.maze_number=0
                  rune.x=rune_coordinate.x
                  rune.y=rune_coordinate.y
	              TecMazeCreater.maze[rune_coordinate.x][rune_coordinate.y].block = 7
				return 20
			end})
end


function TecMazeCreater:GetPosition(x, y)

	return self._corner_bottom_left + (x - 1) * Vector(TEC_MAZE_WALL_SIZE,0,0) +
		(y - 1) * Vector(0,TEC_MAZE_WALL_SIZE,0)

end



function TecMazeCreater:FindClearPlaceforBomb(w,h)
	local MAZE=self.maze
	local maze_coordinate={}
    local x=RandomInt(1,w)
    local y=RandomInt(1,h)
    while MAZE[x][y].block~=0 or self.bombs[x][y]~=nil do
      x=RandomInt(1,w)
      y=RandomInt(1,h)
    end
    maze_coordinate.x=x
    maze_coordinate.y=y
	return maze_coordinate
end


function TecMazeCreater:REC(MAZE, top_right, bottom_left)

    local w=top_right.x-bottom_left.x+1
    local h=top_right.y-bottom_left.y+1
	-- Check if we reached the max level
	if 1<=w and w<=2 and h>2 then   
		 local wall=RandomInt(2,h-1)
		 local hole=RandomInt(1,w)
		 local abs_wall_y=top_right.y-(wall-1)
		 local abs_hole_x=bottom_left.x+hole-1
		 for i=bottom_left.x,top_right.x do
		 	   if abs_hole_x==i then
               MAZE[i][abs_wall_y].block=0
               else
               MAZE[i][abs_wall_y].block=1
               end
         end
         local top_right_new_1=top_right
         local bottom_left_new_1={x=bottom_left.x,y=abs_wall_y+1}
         self:REC(MAZE,top_right_new_1,bottom_left_new_1)
         local top_right_new_2={x=top_right.x,y=abs_wall_y-1}
         local bottom_left_new_2=bottom_left
         self:REC(MAZE,top_right_new_2,bottom_left_new_2)
	end
    if 1<=h and h<=2 and w>2 then   
		 local wall=RandomInt(2,w-1)
		 local hole=RandomInt(1,h)
		 local abs_wall_x=top_right.x-(wall-1)
		 local abs_hole_y=bottom_left.y+hole-1
		 for i=bottom_left.y,top_right.y do
		 	   if abs_hole_y==i then
               MAZE[abs_wall_x][i].block=0
               else
               MAZE[abs_wall_x][i].block=1
               end
         end
         local top_right_new_1=top_right
         local bottom_left_new_1={x=abs_wall_x+1,y=bottom_left.y}
         self:REC(MAZE,top_right_new_1,bottom_left_new_1)
         local top_right_new_2={x=abs_wall_x-1,y=top_right.y}
         local bottom_left_new_2=bottom_left
         self:REC(MAZE,top_right_new_2,bottom_left_new_2)
	end
	if h>2 and w>2 then
		local wall_x=RandomInt(2,w-1)
		local wall_y=RandomInt(2,h-1)
		local abs_wall_x=top_right.x-(wall_x-1)
		local abs_wall_y=top_right.y-(wall_y-1)
		local not_to_dig=RandomInt(1,4)
		local hole_1=RandomInt(1,top_right.x-abs_wall_x) --right
		local hole_2=RandomInt(1,top_right.y-abs_wall_y)  --up
		local hole_3=RandomInt(1,abs_wall_x-bottom_left.x) --left
		local hole_4=RandomInt(1,abs_wall_y-bottom_left.y)  --down
		for i=bottom_left.x,top_right.x do
			for j=bottom_left.y,top_right.y do
		     if i==abs_wall_x or j==abs_wall_y then
				 MAZE[i][j].block=1	
             end
             if i==abs_wall_x+hole_1 and j== abs_wall_y and not_to_dig~=1 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i,y=j-1})
				table.insert(self._skip_hole,{x=i,y=j+1})
             end
             if i==abs_wall_x  and j== abs_wall_y+hole_2 and not_to_dig~=2 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i-1,y=j})
				table.insert(self._skip_hole,{x=i+1,y=j})
             end
             if i==abs_wall_x-hole_3 and j== abs_wall_y and not_to_dig~=3 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i,y=j+1})
				table.insert(self._skip_hole,{x=i,y=j-1})
             end
             if i==abs_wall_x and j == abs_wall_y-hole_4 and not_to_dig~=4 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i-1,y=j})
				table.insert(self._skip_hole,{x=i+1,y=j})
             end
            end
        end
        local top_right_new_1=top_right
        local bottom_left_new_1={x=abs_wall_x+1,y=abs_wall_y+1}
        self:REC(MAZE,top_right_new_1,bottom_left_new_1)
        local top_right_new_2={x=abs_wall_x-1,y=top_right.y}
        local bottom_left_new_2={x=bottom_left.x,y=abs_wall_y+1}
        self:REC(MAZE,top_right_new_2,bottom_left_new_2)
        local top_right_new_3={x=abs_wall_x-1,y=abs_wall_y-1}
        local bottom_left_new_3=bottom_left
        self:REC(MAZE,top_right_new_3,bottom_left_new_3)
        local top_right_new_4={x=top_right.x,y=abs_wall_y-1}
        local bottom_left_new_4={x=abs_wall_x+1,y=bottom_left.y}
        self:REC(MAZE,top_right_new_4,bottom_left_new_4)
    end
    if h<=2 and w<=2 then
    	return
    end
    if h==0 or w==0 then
    	return
    end
end
function BombExplode( keys )
	TecMazeCreater:ExplodeBomb(keys.caster,4)
end

function TecMazeCreater:ExplodeBomb(bomb,power)
	
    local x=bomb.x
    local y=bomb.y
    local MAZE=self.maze
    local w=self.w
    local h=self.h
    StartSoundEventFromPosition ( "Hero_Techies.LandMine.Detonate", bomb:GetOrigin())
	local blastedCells = {}
    for i = 1,w do
		blastedCells[i] = {}	
	end
	for bx=x, math.min(w,x+power) do
		if MAZE[bx][y].block==0 then
			blastedCells[bx][y] = 1			
		else
			break
		end
	end
	
	for bx=x, math.max(1,x-power), -1 do
		if MAZE[bx][y].block==0 then
			blastedCells[bx][y] = 1			
		else
			break
		end
	end
	
	--calculate the reach of the explosion travelling up
	for by=y, math.min(h,y+power) do
		if MAZE[x][by].block==0 then
			blastedCells[x][by] = 1			
		else
			break
		end
	end
	
	--calculate the reach travelling down
	for by=y, math.max(1,y-power), -1 do
		if MAZE[x][by].block==0 then
			blastedCells[x][by] = 1			
		else
			break
		end
	end
	
	--check what we hit
	local hitHeroes = {}
	local hitBombs = {}
	
	for cx=1, w do
		for cy=1,h do
			if blastedCells[cx][cy]==1 then
				local targets = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,self:GetPosition(cx, cy), nil,TEC_MAZE_WALL_SIZE/2+16, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true)
                for i,unit in pairs(targets) do
                local damageTable = {victim=unit,
                                     attacker=bomb,
                                     damage=45,
                                     damage_type=DAMAGE_TYPE_PURE}
                ApplyDamage(damageTable)    --造成伤害
                end
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_CUSTOMORIGIN, bomb)
				ParticleManager:SetParticleControl(particle, 0, self:GetPosition(cx, cy) )-- set position
				if self.bombs[cx][cy] and not (cx == x and cy==y) then
					hitBombs[#hitBombs+1] = {x=cx, y=cy}
				end
			end
		end
	end

   	self.bombs[x][y] = nil
	bomb:RemoveSelf()
	
   for _, bombPos in pairs(hitBombs) do
		local bomb = self.bombs[bombPos.x][bombPos.y]
		if bomb then
			self:ExplodeBomb(bomb,4)
		end
	end

	return 
end


function StasisTrapTracker( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Ability variables
	local activation_radius = 250
	local explode_delay = 1.2
	local vision_radius = 300
	local vision_duration = 1.0
	local modifier_trigger = keys.modifier_trigger

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		caster:SetModel("models/items/techies/bigshot/fx_bigshot_stasis.vmdl")
	    caster:SetOriginalModel("models/items/techies/bigshot/fx_bigshot_stasis.vmdl")
	    caster:StartGesture(ACT_DOTA_SPAWN)
		Timers:CreateTimer(explode_delay, function()
			if caster:IsAlive() then
				ability:ApplyDataDrivenModifier(caster, caster, modifier_trigger, {})
				-- Create vision upon exploding
				ability:CreateVisibilityNode(caster:GetAbsOrigin(), vision_radius, vision_duration)
			end
		end)
	end
end


function StasisTrapRemove( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local activation_radius = 250
	local unit_name = target:GetUnitName()

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local target_types = DOTA_UNIT_TARGET_ALL
	local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		if unit:GetUnitName() == unit_name then
			unit:ForceKill(true) 
		end
	end
end



function HasteRuneTracker( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Ability variables
	local activation_radius = 100
	local modifier_trigger = keys.modifier_trigger

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		for  _,unit in pairs(units) do
			ability:ApplyDataDrivenModifier(caster, unit, modifier_trigger, {})
			StartSoundEvent( "Rune.Haste", unit)
	    end
	    if caster.maze_number==0 then
	    TecMazeCreater.maze[caster.x][caster.y].block = 0
	    elseif  caster.maze_number==1 then
	    MazeCreater.maze[caster.x][caster.y].block = 0
	    end
	    caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0,7000,0))
	    caster:ForceKill(true)
	end
end

function PowerRuneTracker( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Ability variables
	local activation_radius = 100
	local modifier_trigger = keys.modifier_trigger

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		for  _,unit in pairs(units) do
		   ability:ApplyDataDrivenModifier(caster, unit, modifier_trigger, {})
		   StartSoundEvent( "Rune.DD", unit)
	    end
	    if caster.maze_number==0 then
	    TecMazeCreater.maze[caster.x][caster.y].block = 0
	    elseif  caster.maze_number==1 then
	    MazeCreater.maze[caster.x][caster.y].block = 0
	    end
	    caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0,7000,0))
	    caster:ForceKill(true)
	end
end

function ItemRuneTracker( keys )
	local caster = keys.caster
	local ability = keys.ability
    
	-- Ability variables
	local activation_radius = 100

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		dummy_particle = CreateUnitByName('npc_dummy', caster:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
	    local particle_1= ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_hellborn/warlock_rain_of_chaos_hellborn_cast.vpcf",PATTACH_ABSORIGIN,dummy_particle)
	    dummy_particle:ForceKill(true)
	    StartSoundEventFromPosition ( "Rune.Bounty", caster:GetOrigin())
        local rand_number= RandomInt(1,#CourierRunGameMode._HeroItemList)
        local new_item_name=CourierRunGameMode._HeroItemList[rand_number]
        local newItem = CreateItem(new_item_name, nil, nil)
        CreateItemOnPositionSync(caster:GetOrigin(), newItem)
        if caster.maze_number==0 then
	    TecMazeCreater.maze[caster.x][caster.y].block = 0
	    elseif  caster.maze_number==1 then
	    MazeCreater.maze[caster.x][caster.y].block = 0
	    end
        caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0,7000,0))
	    caster:ForceKill(true)
	end
end

function RegenerationRuneTracker( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Ability variables
	local activation_radius = 100
	local modifier_trigger = keys.modifier_trigger

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		for  _,unit in pairs(units) do
			ability:ApplyDataDrivenModifier(caster, unit, modifier_trigger, {})
			StartSoundEvent( "Rune.Regen", unit)
	    end
	    if caster.maze_number==0 then
	    TecMazeCreater.maze[caster.x][caster.y].block = 0
	    elseif  caster.maze_number==1 then
	    MazeCreater.maze[caster.x][caster.y].block = 0
	    end
	    caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0,7000,0))
	    caster:ForceKill(true)
	end
end

function UsefulItemRuneTracker( keys )
	local caster = keys.caster
	local ability = keys.ability
    
	-- Ability variables
	local activation_radius = 100

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		dummy_particle = CreateUnitByName('npc_dummy', caster:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
	    local particle_1= ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_loadout.vpcf",PATTACH_ABSORIGIN,dummy_particle)
	    dummy_particle:ForceKill(true)
	    StartSoundEventFromPosition ("Rune.Invis", caster:GetOrigin())
        local rand_number= RandomInt(1,#CourierRunGameMode._CourierItemList)
        local new_item_name=CourierRunGameMode._CourierItemList[rand_number]
        local newItem = CreateItem(new_item_name, nil, nil)
        CreateItemOnPositionSync(caster:GetOrigin(), newItem)
        if caster.maze_number==0 then
	    TecMazeCreater.maze[caster.x][caster.y].block = 0
	    elseif  caster.maze_number==1 then
	    MazeCreater.maze[caster.x][caster.y].block = 0
	    end
        caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0,7000,0))
	    caster:ForceKill(true)
	end
end
