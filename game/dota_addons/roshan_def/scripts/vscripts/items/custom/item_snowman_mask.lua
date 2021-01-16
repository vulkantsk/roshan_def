LinkLuaModifier("modifier_item_snowman_mask_passive", "items/custom/item_snowman_mask", 0)
LinkLuaModifier("modifier_item_snowman_mask_effect", "items/custom/item_snowman_mask", 0)

item_snowman_mask = class({
	IsHidden = function() return true end,
	GetIntrinsicModifierName = function(self) return "modifier_item_snowman_mask_passive" end,
})
 
function item_snowman_mask:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound("snowman_mask_cast")
	caster:AddNewModifier(caster, self, "modifier_item_snowman_mask_effect", { duration = duration})
end

modifier_item_snowman_mask_passive = class({
	IsHidden = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}end,
})

function modifier_item_snowman_mask_passive:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_snowman_mask_passive:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

modifier_item_snowman_mask_effect = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	IsDebuff = function() return false end,
	IsBuff = function() return true end,
	CheckState = function() return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
	} end,
	GetModifierModelChange = function() return "models/props_frostivus/frostivus_snowman.vmdl" end,
})
