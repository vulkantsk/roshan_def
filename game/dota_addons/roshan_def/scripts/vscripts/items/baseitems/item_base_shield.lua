LinkLuaModifier("modifier_item_base_shield", "items/baseitems/item_base_shield", LUA_MODIFIER_MOTION_NONE)

item_base_shield = class({})

function item_base_shield:GetIntrinsicModifierName()
	return "modifier_item_base_shield"
end

item_base_shield_1 = class(item_base_shield)
item_base_shield_2 = class(item_base_shield)
item_base_shield_3 = class(item_base_shield)

modifier_item_base_shield = class({
	IsHidden 		= function(self) return true end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}end,
})

function modifier_item_base_shield:GetModifierPhysical_ConstantBlock()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end
