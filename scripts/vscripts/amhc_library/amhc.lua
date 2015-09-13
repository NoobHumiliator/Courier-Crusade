----------------------
-- 作者：裸奔的代码
-- 参与者：
-- 创建日期：2015/6/11
-- 修改日期：2015/6/11
----------------------

if AMHC == nil then
	AMHC = class({})
end

--初始化
function AMHCInit()

--------------------
--这里定义私有变量--
--------------------

--颜色
local __msg_type = {}
local __color = {
	red 	={255,0,0},
	orange	={255,127,0},
	yellow	={255,255,0},
	green 	={0,255,0},
	blue 	={0,0,255},
	indigo 	={0,255,255},
	purple 	={255,0,255},
}

--------------------------
--从这里开始定义成员函数--
--------------------------

--====================================================================================================
--函数自动类型判断
--如果某个参数可以是多种类型，用/分隔，比如string/number
function AMHC:Reload( _t, _f, _s )

	--记录参数类型
	local params = {}
	for k in string.gmatch(_s,"[^,]+") do
		table.insert(params,k)
	end

	--存储函数
	local func = _t[_f]

	--重写函数
	_t[_f] = function( self,... )
		local args = {...}

		--是否有多余参数
		if #args > #params then
			error("AMHC:".._f.." called with "..tostring(#args).." arguments - expected "..tostring(#params),2)
		end

		--检测类型
		for k,v in pairs(args) do
			local _type = type(v)
			if string.find(params[k],'/') ~= nil then

				local x = false
				for s in string.gmatch(params[k],"[^/]+") do
					if _type ~= s then
						x = true
					else
						x = false
						break
					end
				end
	
				if x then
					error("AMHC:".._f.." param "..tostring(k-1).." is not "..params[k],2)
				end
			else
				if _type ~= params[k] then
					error("AMHC:".._f.." param "..tostring(k-1).." is not "..params[k],2)
				end
			end
		end

		--调用原来的函数
		return func( self,...)
	end
end
--====================================================================================================
--判断实体有效，存活，非存活于一体的函数
--返回true	有效且存活
--返回false	有效但非存活
--返回nil	无效实体
function AMHC:IsAlive( ... )
	local entity = ...
	if IsValidEntity(entity) then
		if entity:IsAlive() then
			return true
		end
		return false
	end
	return nil
end
AMHC:Reload( AMHC, "IsAlive", "table" )
--====================================================================================================


--====================================================================================================
--创建计时器

function AMHC:Timer( ... )
	local name,fun,delay,entity = ...

	delay = delay or 0

	local ent = nil;
	if(entity ~= nil)then
		if self:IsAlive(entity)==nil then
			error("AMHC:Timer param 3: not valid entity",2);
		end
		ent = entity;
	else
		ent = GameRules:GetGameModeEntity();
	end

	local time = GameRules:GetGameTime()
	ent:SetContextThink(DoUniqueString(name),function( )

		if GameRules:GetGameTime()-time >= delay then
			ent:SetContextThink(DoUniqueString(name),function( )

				if not GameRules:IsGamePaused() then
					return fun();
				end

				return 0.01
			end,0)
			return nil
		end

		return 0.01
	end,0)
		
end
AMHC:Reload( AMHC, "Timer", "string,function,number,table" )

--便于实体直接调用
function CBaseEntity:Timer(fun,delay)
	AMHC:Timer( self:GetClassname()..tostring(RandomInt(1,10000)),fun,delay,self )
end

--====================================================================================================


--====================================================================================================
--创建带有计时器的特效，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticle(...)
	
	local particleName,particleAttach,immediately,owningEntity,duration,callback = ...
	
	local p = ParticleManager:CreateParticle(particleName,particleAttach,owningEntity)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end
AMHC:Reload( AMHC, "CreateParticle", "string,number,boolean,table,number,function" )

--创建带有计时器的特效，只对某玩家显示，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticleForPlayer(...)
	local particleName,particleAttach,immediately,owningEntity,owningPlayer,duration,callback = ...
	
	local p = ParticleManager:CreateParticleForPlayer(particleName,particleAttach,owningEntity,owningPlayer)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end
AMHC:Reload( AMHC, "CreateParticleForPlayer", "string,number,boolean,table,table,number,function" )
--====================================================================================================


--====================================================================================================
--定义常量
AMHC.MSG_BLOCK 		= "particles/msg_fx/msg_block.vpcf"
AMHC.MSG_ORIT 		= "particles/msg_fx/msg_crit.vpcf"
AMHC.MSG_DAMAGE 	= "particles/msg_fx/msg_damage.vpcf"
AMHC.MSG_EVADE 		= "particles/msg_fx/msg_evade.vpcf"
AMHC.MSG_GOLD 		= "particles/msg_fx/msg_gold.vpcf"
AMHC.MSG_HEAL 		= "particles/msg_fx/msg_heal.vpcf"
AMHC.MSG_MANA_ADD 	= "particles/msg_fx/msg_mana_add.vpcf"
AMHC.MSG_MANA_LOSS 	= "particles/msg_fx/msg_mana_loss.vpcf"
AMHC.MSG_MISS 		= "particles/msg_fx/msg_miss.vpcf"
AMHC.MSG_POISION 	= "particles/msg_fx/msg_poison.vpcf"
AMHC.MSG_SPELL 		= "particles/msg_fx/msg_spell.vpcf"
AMHC.MSG_XP 		= "particles/msg_fx/msg_xp.vpcf"

table.insert(__msg_type,AMHC.MSG_BLOCK)
table.insert(__msg_type,AMHC.MSG_ORIT)
table.insert(__msg_type,AMHC.MSG_DAMAGE)
table.insert(__msg_type,AMHC.MSG_EVADE)
table.insert(__msg_type,AMHC.MSG_GOLD)
table.insert(__msg_type,AMHC.MSG_HEAL)
table.insert(__msg_type,AMHC.MSG_MANA_ADD)
table.insert(__msg_type,AMHC.MSG_MANA_LOSS)
table.insert(__msg_type,AMHC.MSG_MISS)
table.insert(__msg_type,AMHC.MSG_POISION)
table.insert(__msg_type,AMHC.MSG_SPELL)
table.insert(__msg_type,AMHC.MSG_XP)

--显示数字特效，可指定颜色，符号
function AMHC:CreateNumberEffect( ... )
	local entity,number,duration,msg_type,color,icon_type = ...

	--判断实体
	if self:IsAlive(entity)==nil then
		return
	end

	icon_type = icon_type or 9

	--对采用的特效进行判断
	local is_msg_type = false
	for k,v in pairs(__msg_type) do
		if msg_type == v then
			is_msg_type = true;
			break;
		end
	end

	if not is_msg_type then
		error("AMHC:CreateNumberEffect param 3: not valid msg type;example:AMHC.MSG_GOLD",2);
	end

	--判断颜色
	if type(color)=="string" then
		color = __color[color] or {255,255,255}
	else
		if #color ~=3 then
			error("AMHC:CreateNumberEffect param 4: color error; format example:{255,255,255}",2);
		end
	end
	local color_r = tonumber(color[1]) or 255;
	local color_g = tonumber(color[2]) or 255;
	local color_b = tonumber(color[3]) or 255;
	local color_vec = Vector(color_r,color_g,color_b);

	--处理数字
	number = math.floor(number)
	local number_count = #tostring(number) + 1

	--创建特效
    local particle = AMHC:CreateParticle(msg_type,PATTACH_CUSTOMORIGIN_FOLLOW,false,entity,duration)
    ParticleManager:SetParticleControlEnt(particle,0,entity,5,"attach_hitloc",entity:GetOrigin(),true)
    ParticleManager:SetParticleControl(particle,1,Vector(10,number,icon_type))
    ParticleManager:SetParticleControl(particle,2,Vector(duration,number_count,0))
    ParticleManager:SetParticleControl(particle,3,color_vec)
end
AMHC:Reload(AMHC,"CreateNumberEffect","table,number,number,string,table/string,number")
--====================================================================================================
end