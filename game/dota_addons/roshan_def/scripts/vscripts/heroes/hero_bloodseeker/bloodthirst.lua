LinkLuaModifier("modifier_bloodseeker_bloodthirst", "heroes/hero_bloodseeker/bloodthirst.lua", 0)

bloodseeker_bloodthirst = class({})

function bloodseeker_bloodthirst:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_bloodseeker_bloodthirst", {duration = duration})
end

modifier_bloodseeker_bloodthirst = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, 
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
	} end,
	GetEffectName = function() return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_bloodseeker_bloodthirst:GetModifierBaseAttackTimeConstant() 
	return self:GetAbility():GetSpecialValueFor("bat_decrease") 
end

function modifier_bloodseeker_bloodthirst:GetModifierMoveSpeedBonus_Constant() 
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus") 
end