LinkLuaModifier("modifier_ability_example", "abilities/ability_example", LUA_MODIFIER_MOTION_NONE)

ability_example = class({})

function ability_example:GetIntrinsicModifierName()
	return "modifier_ability_example"
end

modifier_ability_example = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
--	GetAttributes 			= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		} end,
})
function modifier_ability_example:GetModifierBonusStats_Strength()
	return self:GetStackCount() or 0
end
