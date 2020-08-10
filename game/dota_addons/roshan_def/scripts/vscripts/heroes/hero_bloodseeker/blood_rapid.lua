LinkLuaModifier("modifier_bloodseeker_blood_rapid", "heroes/hero_bloodseeker/blood_rapid.lua", 0)

bloodseeker_blood_rapid = class({GetIntrinsicModifierName = function() return "modifier_bloodseeker_blood_rapid" end})

modifier_bloodseeker_blood_rapid = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
})

function modifier_bloodseeker_blood_rapid:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct") end