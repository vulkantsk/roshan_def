LinkLuaModifier("modifier_item_watermelon_skin_passive", "items/custom/item_watermelon_skin", 0)
LinkLuaModifier("modifier_item_watermelon_skin_effect", "items/custom/item_watermelon_skin", 0)

item_watermelon_skin = class({
	IsHidden = function() return true end,
	GetIntrinsicModifierName = function(self) return "modifier_item_watermelon_skin_passive" end,
})
 
function item_watermelon_skin:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_item_watermelon_skin_effect", { duration = duration})
end

modifier_item_watermelon_skin_passive = class({
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}end,
})

function modifier_item_watermelon_skin_passive:GetModifierHealthBonus()
	return self:GetSpecialValueFor("bonus_health")
end

function modifier_item_watermelon_skin_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

modifier_item_watermelon_skin_effect = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	IsDebuff = function() return false end,
	IsBuff = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	} end,
	GetModifierModelChange = function() return "models/event/arbus/arbuz.vmdl" end,
	GetEffectName = function() return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf" end
})

function modifier_item_watermelon_skin_effect:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("buff_regen")
end

function modifier_item_watermelon_skin_effect:OnCreated()
	EmitSoundOn("Hero_Treant.Overgrowth.Cast", self:GetCaster())
end
