TIMERS_THINK = 0.1

if Timers == nil then
  Timers = {}
  Timers.__index = Timers
end

function Timers:new( o )
  o = o or {}
  setmetatable( o, Timers )
  return o
end

function Timers:start()
  print ( '[TIMERS] Creating Timers' )
  
  Timers = self
  self.timers = {}

  GameRules:GetGameModeEntity():SetThink("Think", self, "timers", TIMERS_THINK)
end

function Timers:Think()
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return
  end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()

  -- Process timers
  for k,v in pairs(Timers.timers) do
    local bUseGameTime = true
    if v.useGameTime ~= nil and v.useGameTime == false then
      bUseGameTime = false
    end

    local now = GameRules:GetGameTime()
    if not bUseGameTime then
      now = Time()
    end

    if v.endTime == nil then
      v.endTime = now
    end
    -- Check if the timer has finished
    if now >= v.endTime then
      -- Remove from timers list
      Timers.timers[k] = nil
      
      -- Run the callback
      local status, nextCall = pcall(v.callback, GameRules:GetGameModeEntity(), v)

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall then
          -- Change its end time
          v.endTime = v.endTime + nextCall

          Timers.timers[k] = v
        end
      else
        -- Nope, handle the error
        Timers:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return TIMERS_THINK
end

function Timers:HandleEventError(name, event, err)
  print(err)

  -- Ensure we have data
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- Prevent loop arounds
  if not self.errorHandled then
    -- Store that we handled an error
    self.errorHandled = true
  end
end

function Timers:CreateTimer(name, args)
  if type(name) == "function" then
    args = {callback = name}
    name = DoUniqueString("timer")
  elseif type(name) == "table" then
    args = name
    name = DoUniqueString("timer")
  elseif type(name) == "number" then
    args = {endTime = name, callback = args}
    name = DoUniqueString("timer")
  end
  
  if not args.callback then
    print("[TIMERS] Invalid timer created: "..name)
    return
  end

  local now = GameRules:GetGameTime()
  if args.useGameTime ~= nil and args.useGameTime == false then
    now = Time()
  end

  if args.endTime == nil then
    args.endTime = now
  else
  	args.endTime = now + args.endTime
  end

  Timers.timers[name] = args 

  return name
end

function Timers:RemoveTimer(name)
  Timers.timers[name] = nil
end

function Timers:RemoveTimers(killAll)
  local timers = {}

  if not killAll then
    for k,v in pairs(Timers.timers) do
      if v.persist then
        timers[k] = v
      end
    end
  end

  Timers.timers = timers
end