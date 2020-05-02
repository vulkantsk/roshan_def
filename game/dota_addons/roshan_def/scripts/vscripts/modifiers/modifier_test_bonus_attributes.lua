modifier_test_bonus_attributes = class({
	DeclareFunctions = function(self)
		return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	end,
	OnCreated = function(self)
		self.parent = self:GetParent()
		self.primaryAttribute = self.parent:GetPrimaryAttribute()
	end,
	GetModifierBonusStats_Strength = function(self)
		if self.strBonus or self.primaryAttribute ~= DOTA_ATTRIBUTE_STRENGTH then return 0 end
		self.strBonus = true
		local bonus = self.parent:GetStrength() * 0.2
		self.strBonus = false
		return bonus
	end,

	GetModifierBonusStats_Agility = function(self)
		if self.agiBonus or self.primaryAttribute ~= DOTA_ATTRIBUTE_AGILITY then return 0 end
		self.agiBonus = true
		local bonus = self.parent:GetAgility() * 0.2
		self.agiBonus = false
		return bonus
	end,

	GetModifierBonusStats_Intellect = function(self)
		if self.intBonus or self.primaryAttribute ~= DOTA_ATTRIBUTE_INTELLECT then return 0 end
		self.intBonus = true
		local bonus = self.parent:GetIntellect() * 0.2
		self.intBonus = false
		return bonus
	end,
})
LinkLuaModifier("modifier_test_bonus_attributes", "modifiers/modifier_test_bonus_attributes", LUA_MODIFIER_MOTION_NONE)
