LinkLuaModifier("modifier_item_skull_of_midas", "items/custom/item_kirk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_kirk", "items/custom/item_kirk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_kirk_gold", "items/custom/item_kirk", LUA_MODIFIER_MOTION_NONE)

item_skull_of_midas = item_skull_of_midas or class({})

function item_skull_of_midas:GetIntrinsicModifierName()
	return "modifier_item_skull_of_midas"
end

function item_skull_of_midas:OnSpellStart()
	Sounds:CreateGlobalSound( "LakadMatatag" )
end
modifier_item_skull_of_midas = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_DEATH
	}end,
})

function modifier_item_skull_of_midas:OnDeath(data)
	local attacker = data.attacker
	local caster = self:GetCaster()
	local unit = data.unit
	
	if attacker == caster and caster:IsAlive() and unit:GetTeam()~=caster:GetTeam() then 
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("chance")
		local gold = ability:GetSpecialValueFor("gold")
		local xp = ability:GetSpecialValueFor("xp")
		if RollPercentage(chance) then
			local player = PlayerResource:GetPlayer(caster:GetPlayerID())
			caster:AddExperience(xp, 0, false, true )
			caster:ModifyGold(gold, false, 0)
			SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, caster, gold, nil )
		end	
	end			
end
item_kirk = item_kirk or class({})

function item_kirk:GetIntrinsicModifierName()
	return "modifier_item_kirk"
end

modifier_item_kirk = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_DEATH
	}end,
})

function modifier_item_kirk:OnDeath(data)
	local attacker = data.attacker
	local caster = self:GetCaster()
	local unit = data.unit
	
	if attacker == caster and caster:IsAlive() and unit:GetTeam()~=caster:GetTeam() then 
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("chance")
		local gold = ability:GetSpecialValueFor("gold")
		local xp = ability:GetSpecialValueFor("xp")
		if RollPercentage(chance) then
			local player = PlayerResource:GetPlayer(caster:GetPlayerID())
			caster:AddExperience(xp, 0, false, true )
			caster:ModifyGold(gold, false, 0)
			SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, caster, gold, nil )
		end	
	end		
end

item_kirk_gold = item_kirk_gold or class({})

function item_kirk_gold:GetIntrinsicModifierName()
	return "modifier_item_kirk_gold"
end

function item_kirk_gold:OnSpellStart()
	local caster = self:GetCaster()
	local xp = self:GetSpecialValueFor("xp")
	local gold = self:GetSpecialValueFor("gold")
	local extra_xp = self:GetSpecialValueFor("extra_xp")
	local extra_gold = self:GetSpecialValueFor("extra_gold")
	local chance = self:GetSpecialValueFor("chance")

	if RollPercentage(chance) then
		GiveGoldPlayers(extra_gold)
		GiveExperiencePlayers(extra_xp)
		Sounds:CreateGlobalSound( "Hero_OgreMagi.Fireblast.x3" )
	else
		GiveGoldPlayers(gold)
		GiveExperiencePlayers(xp)
	end
end

modifier_item_kirk_gold = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_DEATH
	}end,
})

function modifier_item_kirk_gold:OnDeath(data)
	local attacker = data.attacker
	local caster = self:GetCaster()
	local unit = data.unit
	
	if attacker == caster and caster:IsAlive() and unit:GetTeam()~=caster:GetTeam() then 
		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("chance")
		local gold = ability:GetSpecialValueFor("gold")
		local xp = ability:GetSpecialValueFor("xp")
		if RollPercentage(chance) then
			local player = PlayerResource:GetPlayer(caster:GetPlayerID())
			caster:AddExperience(xp, 0, false, true )
			caster:ModifyGold(gold, false, 0)
			SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, caster, gold, nil )
		end	
	end				
end
