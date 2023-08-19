
function GiveNewHero(keys) 
	local caster = keys.caster 
	local playerID = caster:GetPlayerID()
	local oldHero = caster--PlayerResource:GetSelectedHeroEntity(playerID)	
	local newHeroName = keys.hero_name
	local gold = oldHero:GetGold()
	local experience = oldHero:GetCurrentXP() 
	print("gold = "..gold.." exp = "..experience)
	if not PlayerResource:IsValidPlayer(playerID) or not PlayerResource:GetPlayer(playerID) then
		return
	end
	
	if playerID ~= nil and playerID ~= -1 then 
		caster:ForceKill(false)
		items_table = {} 
		for i = 0, 23 do 
			local item = oldHero:GetItemInSlot( i ) 
			if item ~= nil then 
				items_table[item:GetName()] = item:GetCurrentCharges() 
				item:RemoveSelf() 
			end 
		end 
		local newHero = PlayerResource:ReplaceHeroWith(playerID, newHeroName, 0, 0) 
		newHero:RespawnHero(false, false) 
		
		newHero:SetGold(gold, false)
		newHero:AddExperience(experience, 0, false, true)
		for item,stacks in pairs(items_table) do 
			local item = newHero:AddItemByName(item) 
			item:UseResources(false, false, true, false)
			item:SetCurrentCharges(stacks)
		end 
	end 
end