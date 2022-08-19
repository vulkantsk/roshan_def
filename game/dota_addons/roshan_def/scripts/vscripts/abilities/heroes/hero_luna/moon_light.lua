LinkLuaModifier("modifier_luna_moon_light_buff", "abilities/heroes/hero_luna/moon_light", LUA_MODIFIER_MOTION_NONE)

luna_moon_light = class({
	GetIntrinsicModifierName = function() 
		return "modifier_luna_moon_light_buff" 
	end
})

modifier_luna_moon_light_buff = class({
	IsHidden = function() return true  end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	} end
})

function modifier_luna_moon_light_buff:OnCreated()
	self.ability = self:GetAbility()
	self:OnRefresh()
	if(not IsServer()) then
		return
	end
	self:OnIntervalThink()
	self:StartIntervalThink(1)
end

function modifier_luna_moon_light_buff:OnRefresh()
    self.ability = self:GetAbility() or self.ability
    if(not self.ability) then
        return
    end
	self.bonus_ms_pct = self.ability:GetSpecialValueFor("bonus_ms_pct")
	self.bonus_evasion = self.ability:GetSpecialValueFor("bonus_evasion")
	self.bonus_magic_resist = self.ability:GetSpecialValueFor("bonus_magic_resist")
end

function modifier_luna_moon_light_buff:OnIntervalThink()
	if(GameRules:IsDaytime()) then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

function modifier_luna_moon_light_buff:IsHidden()
	return self:GetStackCount() == 1
end

function modifier_luna_moon_light_buff:GetModifierMoveSpeedBonus_Percentage()
	if(self:GetStackCount() == 0) then
		return self.bonus_ms_pct
	end
	return 0
end

function modifier_luna_moon_light_buff:GetModifierEvasion_Constant()
	if(self:GetStackCount() == 0) then
		return self.bonus_evasion
	end
	return 0
end

function modifier_luna_moon_light_buff:GetModifierMagicalResistanceBonus()
	if(self:GetStackCount() == 0) then
		return self.bonus_magic_resist
	end
	return 0
end

