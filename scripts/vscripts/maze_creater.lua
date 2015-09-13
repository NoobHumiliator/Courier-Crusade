DX = {0, 1, 0, -1}
DY = {1, 0, -1, 0}

DX_DIAG = {1, 1, -1, -1}
DY_DIAG = {1, -1, -1, 1}

MINIGAME_START_DELAY = 5

if MazeCreater == nil then
	MazeCreater = class({})
end

MAZE_WALL_SIZE = 160
MAZE_GUARDIAN_CHANCE = 15
MAZE_CAMERA_DISTANCE = 800

function MazeCreater:Init()

	-- Find the environment parameters of the MAZE
	self._corner_bottom_left = Entities:FindByName(nil, "MAZE_corner_bottom_left"):GetAbsOrigin()
	self._corner_top_right = Entities:FindByName(nil, "MAZE_corner_top_right"):GetAbsOrigin()

	local size = self._corner_top_right - self._corner_bottom_left
	local w = math.floor(math.abs(size.x) / MAZE_WALL_SIZE) + 1
	local h = math.floor(math.abs(size.y) / MAZE_WALL_SIZE) + 1
	
	if w % 2 == 0 then w = w - 1 end
	if h % 2 == 0 then h = h - 1 end

	-- Generate a random MAZE
	local MAZE = {}
	
	-- Initialize a full grid
	for i = 1,w do
		MAZE[i] = {}
		for j = 1,h do
			MAZE[i][j] = {block = 1, used = false}
		end
	end
	
	-- Initialize starting point
	local start_x = 2
	local start_y = 8
	

	-- Make paths with a DFS
	self._max_level = 0
	self:DFS(MAZE, w, h, start_x, start_y, 1)
	
	-- Make the MAZE accessible from the outside
	MAZE[start_x - 1][start_y].block = 0
	MAZE[w][math.floor(h/2)].block = 0
	MAZE[14][9].block=0  --roshan shop
	MAZE[14][8].block=0
	MAZE[14][10].block=0
	MAZE[15][9].block=0
	MAZE[13][9].block=0
	-- Add guardians	
	for i = 2,w-1 do
		for j = 2,h-1 do
			for k = 0,1 do
				p = (k == 0) and {1, 0, 1, 0} or {0, 1, 0, 1}
				
				if MAZE[i][j].block == 1 and 
				   MAZE[i + DX[1]][j + DY[1]].block == p[1] and
				   MAZE[i + DX[2]][j + DY[2]].block == p[2] and
				   MAZE[i + DX[3]][j + DY[3]].block == p[3] and
				   MAZE[i + DX[4]][j + DY[4]].block == p[4] then
					if RandomInt(1,100) <= MAZE_GUARDIAN_CHANCE then
						MAZE[i][j].block = 6
						for l = 1,4 do
							if p[l] == 1 then
								MAZE[i + DX[l]][j + DY[l]].block = 2 + (l + 1) % 4
							end
						end
					end
				end
			end
		end
	end
	self.maze=MAZE
	-- Create the MAZE
	for i = 1,w do
		for j = 1,h do
			local position = self:GetPosition(i, j)
			local block = MAZE[i][j].block		
			if 1 <= block and block <= 5 then
				local name = "npc_maze_" .. ((block == 1) and "wall" or "guard")
				local wall = CreateUnitByName(name, position,false, nil, nil, DOTA_TEAM_NEUTRALS)
				wall:SetHullRadius(MAZE_WALL_SIZE / 2 + 2)
				  if block > 1 then
				  wall:SetForwardVector(self:GetPosition(i + DX[block - 1],j + DY[block - 1]) - position)
				  wall:SetAbsOrigin(wall:GetAbsOrigin() - wall:GetForwardVector()*40)
				  local basket = CreateUnitByName("npc_maze_basket",position,false, nil, nil, DOTA_TEAM_NEUTRALS)
				  basket:SetHullRadius(0)
			      end
			elseif block == 6 then
				 local trap = CreateUnitByName("npc_maze_trap", position,false, nil, nil, DOTA_TEAM_NEUTRALS)
				 --[[ApplyCustomModifier(trap, "trap_fire", "trap_fire")]]
				 trap:SetAbsOrigin(trap:GetAbsOrigin() + Vector(0,0,32))
			end
		end
	end
   Timers:CreateTimer({
   	              endTime = 3,
			      callback =function()
				  local maze_hole={}
                   for i=1,h do
   	                  table.insert(maze_hole,0)
                   end
                   for i=1,5 do
   	                 local random_number=RandomInt(1,h)
   	                 while maze_hole[random_number]==1 do
                        random_number=RandomInt(1,h)
   	                 end
                     maze_hole[random_number]=1
                   end
                   for i=1,h do
                     if maze_hole[i]==0 then
                     local position=MazeCreater:GetPosition(w,i)
                     CreateUnitByName("npc_maze_fire_wall", position,false, nil, nil, DOTA_TEAM_NEUTRALS)
                     end 
                   end  
				return 55
			end})
   Timers:CreateTimer({
   	              endTime = 20,
			      callback = function()
   	              local rune=nil 
				  local rune_coordinate=MazeCreater:FindClearPlaceforRune(w,h)
                  local position=MazeCreater:GetPosition(rune_coordinate.x,rune_coordinate.y)
                  local c = RandomInt(1,839)
	              if c >= 1 and c <200 then
		          rune = CreateUnitByName('maze_haste_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
		          print("haste_rune")
	              elseif c >= 200 and c <400 then
		          rune = CreateUnitByName('maze_power_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
		          print("power_rune")
	              elseif c >= 400 and c <600 then
		          rune = CreateUnitByName('maze_item_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
		          print("item_rune")
		          elseif c >= 600 and c <800 then
		          rune = CreateUnitByName('maze_regeneration_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
		          print("regeneration_rune")
		          elseif c >= 800 and c <839 then
		          rune = CreateUnitByName('maze_useful_item_rune', position, false, nil, nil, DOTA_TEAM_NEUTRALS)
		          print("useful_item_rune")
                  end
                  rune.maze_number=1
                  rune.x=rune_coordinate.x
                  rune.y=rune_coordinate.y
	              MazeCreater.maze[rune_coordinate.x][rune_coordinate.y].block = 7
				return 20
			end})

end


function MazeCreater:GetPosition(x, y)

	return self._corner_bottom_left + (x - 1) * Vector(MAZE_WALL_SIZE,0,0) +
		(y - 1) * Vector(0,MAZE_WALL_SIZE,0)

end

function MazeCreater:FindClearPlaceforRune(w,h)
	local MAZE=self.maze
	local maze_coordinate={}
    local x=RandomInt(1,w)
    local y=RandomInt(1,h)
    while MAZE[x][y].block~=0 do
      x=RandomInt(1,w)
      y=RandomInt(1,h)
    end
    maze_coordinate.x=x
    maze_coordinate.y=y
	return maze_coordinate
end


function MazeCreater:DFS(MAZE, w, h, x, y, level)

	-- Check if we reached the max level
	if level > self._max_level then
		self._max_level = level
		self._finish_x = x
		self._finish_y = y
	end

	-- Set cell as used
	MAZE[x][y].block = 0
	MAZE[x][y].used = true

	-- Randomize the order in which we explore
	local shuffled = ShuffleList({1, 2, 3, 4})

	-- Explore adjecent cells
	for i = 1,4 do
		local nx = x + 2 * DX[shuffled[i]]
		local ny = y + 2 * DY[shuffled[i]]
		
		if 1 <= nx and nx <= w and 1 <= ny and ny <= h and not MAZE[nx][ny].used then
			MAZE[x + DX[shuffled[i]]][y + DY[shuffled[i]]].block = 0
			
			self:DFS(MAZE, w, h, nx, ny, level + 1)
		end
	end

end
