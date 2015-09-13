require("lib/bmd_timers")
function ultimateblink(keys)
	local caster = keys.caster
	if(caster.ultimate_blink_flag==1)then
		return
	end
	print("wtf!!!")
	
	local vecMove = caster:GetOrigin() + keys.BlinkRange * caster:GetForwardVector()
	caster:SetOrigin(vecMove)

	if caster.ultimate_blink_flag==0 or caster.ultimate_blink_flag==nil then
		caster.ultimate_blink_flag=1
		
		 Timers:CreateTimer({
   	              endTime = 0.1,
			      callback =function()
				   caster.ultimate_blink_flag=0
				return nil
			end})
	end
end
