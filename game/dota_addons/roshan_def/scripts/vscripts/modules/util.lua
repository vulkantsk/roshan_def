function extends(child, parent)
    setmetatable(child,{__index = parent}) 
    return child
end

__util__ = {
	PlayerEach 	= function(callback)
		if not callback then print('Not Callback Function!')  return end
		for i = 0, DOTA_MAX_PLAYERS - 1 do
			if PlayerResource:IsValidPlayer(i) then
				callback(i)
			end
		end
	end,
	IsBot 		= function(pID)
		return PlayerResource:GetSteamAccountID(pID) < 1000
	end,
	TrueKill 	= function(target,caster, ability)
		target:Kill(ability, caster)
		if not target:IsNull() and target:IsAlive() then
			
			for k,v in pairs(target:FindAllModifiers()) do
				v:Destroy()
			end
			target:Kill(ability, caster)
		end	
	end,
	GetDirectoryFromPath	= function(path)
		return path:match("(.*[/\\])")
	end,

	ModuleRequire			= function(path,file)
		return require(__util__.GetDirectoryFromPath(path) .. file)
	end,
	table 	= {
		merge 	= function(input1,input2) 
			for i,v in pairs(input2) do
				input1[i] = v
			end
			return input1
		end,
	},
}

-- extends by main clas __util__
__request_util__ = extends(__util__,{	
	RequestData	= function(url,data,callback)
		local dataRequest = json.encode({
			data = data,
			__authKey = request.__authKey,
		})
	    local req = CreateHTTPRequestScriptVM('POST', request.__http .. url .. '.php')
		req:SetHTTPRequestGetOrPostParameter("Data", dataRequest )
		req:Send(function(response)
	        if response.StatusCode ~= 200 then  
	        	print("Error, Status code = ",response.StatusCode) 
	        	if request.__http == 'https://roshan-defense.com/dota_api/' then 
		        	request.__http = 'http://roshan-defense.com/dota_api/'
		        	__request_util__.RequestData(url,data,callback)
	        	end
	        	return 
	        end
	        print('request response')
			local obj, pos, err = json.decode(response.Body)
			if not obj or type(obj) ~= "table" or obj == '' then 
				print("Error, object not found, obj = '" .. tostring(obj) .. "' type = ",type(obj)) 
				return 
			end
	        if callback and obj and type(obj) == "table" then
				callback(obj)
	        end
	    end)
	end,
})
-- DOTA WTF !!! ERROR
function CDOTA_BaseNPC:GetMoveCapability() 
	return 	self:HasGroundMovementCapability() and DOTA_UNIT_CAP_MOVE_GROUND or 
			self:HasFlyMovementCapability() and DOTA_UNIT_CAP_MOVE_FLY or 
			DOTA_UNIT_CAP_MOVE_NONE 
end

function CDOTA_BaseNPC:IteratorModifiers(callback)
	if not callback then return end
	for k,v in pairs(self:FindAllModifiers()) do
		if callback(v) == false then 
			break
		end
	end
end


--[[
	ability
	modifier
	duration
	count
	updateStack
	caster
	data
]]

function CDOTA_BaseNPC:AddStackModifier(data)
	data.data = data.data or {}
	data.data.duration = (data.duration or -1)
	if self:HasModifier(data.modifier) then
		local current_stack = self:GetModifierStackCount( data.modifier, data.ability )
		if data.updateStack then
			self:AddNewModifier(data.caster or self, data.ability,data.modifier,data.data)
		end
		self:SetModifierStackCount( data.modifier, data.ability, current_stack + (data.count or 1) )
		if self:GetModifierStackCount( data.modifier, data.ability ) < 1 then
			self:RemoveModifierByName(data.modifier)
		end
	else
		self:AddNewModifier(data.caster or self, data.ability,data.modifier,data.data)
		self:SetModifierStackCount( data.modifier, data.ability, (data.count or 1) )
	end
	return self:GetModifierStackCount( data.modifier, data.ability )
end
