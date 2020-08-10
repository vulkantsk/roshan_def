LinkLuaModifier("modifier_item_leaf", "items/custom/item_leaf", LUA_MODIFIER_MOTION_NONE)

item_leaf = class({})

function item_leaf:GetIntrinsicModifierName()
	return "modifier_item_leaf"
end
--------------------------------------------------------
------------------------------------------------------------
modifier_item_leaf = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		} end,
})

function modifier_item_leaf:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_leaf:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regen")
end
function modifier_item_leaf:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

item_leaf_1 = class(item_leaf)
item_leaf_2 = class(item_leaf)
item_leaf_3 = class(item_leaf)
item_leaf_4 = class(item_leaf)
item_leaf_5 = class(item_leaf)
item_leaf_6 = class(item_leaf)
item_leaf_7 = class(item_leaf)
