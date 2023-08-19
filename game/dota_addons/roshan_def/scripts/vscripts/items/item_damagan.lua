LinkLuaModifier( "modifier_item_damagan", "items/item_damagan", LUA_MODIFIER_MOTION_NONE )

item_damagan = class({})

function item_damagan:GetIntrinsicModifierName()
	return "modifier_item_damagan" 
end

-----------------------------------------------------------------------------------------------------------
--	Javelin owner bonus attributes (stackable)
-----------------------------------------------------------------------------------------------------------

modifier_item_damagan = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}end,
})

function modifier_item_damagan:OnCreated(keys)
	if IsServer() then
		self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_damagan:OnRefresh(keys)
	if IsServer() then
		self:OnCreated(keys)
	end
end

function modifier_item_damagan:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end
