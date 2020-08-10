LinkLuaModifier("modifier_item_special_invoker", "heroes/hero_invoker/item_special_invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_special_invoker_upgrade", "heroes/hero_invoker/item_special_invoker", LUA_MODIFIER_MOTION_NONE)

item_special_invoker = class({})

function item_special_invoker:GetIntrinsicModifierName()
	return "modifier_item_special_invoker"
end

modifier_item_special_invoker = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		} end,
})

function modifier_item_special_invoker:OnCreated()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()

end

function modifier_item_special_invoker:OnDestroy()
	local caster = self:GetCaster()
end

function modifier_item_special_invoker:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_special_invoker:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_special_invoker:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_special_invoker:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_special_invoker:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_manareg")
end

function modifier_item_special_invoker:GetEffectName()
	if self:GetCaster():GetUnitName()=="npc_dota_hero_invoker" then
		return "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf"
	else
		return
	end	
end

item_special_invoker_upgrade = class({})

function item_special_invoker_upgrade:GetIntrinsicModifierName()
	return "modifier_item_special_invoker_upgrade"
end

modifier_item_special_invoker_upgrade = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		} end,
})

function modifier_item_special_invoker_upgrade:OnCreated()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
end
function modifier_item_special_invoker_upgrade:OnDestroy()
	local caster = self:GetCaster()
end

function modifier_item_special_invoker_upgrade:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_special_invoker_upgrade:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_special_invoker_upgrade:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_special_invoker_upgrade:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_special_invoker_upgrade:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_manareg")
end
function modifier_item_special_invoker_upgrade:GetEffectName()
	if self:GetCaster():GetUnitName()=="npc_dota_hero_invoker" then
		return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
	else
		return
	end	
end
