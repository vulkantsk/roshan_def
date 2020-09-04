LinkLuaModifier("modifier_jakiro_cold_mind", "heroes/hero_jakiro/cold_mind", 0)
LinkLuaModifier("modifier_jakiro_cold_mind_debuff", "heroes/hero_jakiro/cold_mind", 0)
LinkLuaModifier("modifier_jakiro_cold_mind_cooldown", "heroes/hero_jakiro/cold_mind", 0)'

jakiro_cold_mind = class({
	GetIntrinsicModifierName = function() return "jakiro_cold_mind" end
})

jakiro_cold_mind = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() 