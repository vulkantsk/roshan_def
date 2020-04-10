LinkLuaModifier("modifier_meepo_digger_elixir", "heroes/hero_meepo/digger_elixir", LUA_MODIFIER_MOTION_NONE)

meepo_digger_elixir = class({})

function meepo_digger_elixir:OnSpellStart()
	local caster = self:GetCaster()
	local buff_duration = self:GetSpecialValueFor("buff_duration")
	caster:EmitSound("meepo_meepo_doubdam_0"..RandomInt(1, 2))

	caster:AddNewModifier(caster, self, "modifier_meepo_digger_elixir", {duration = buff_duration})
end
--------------------------------------------------------
------------------------------------------------------------
modifier_meepo_digger_elixir = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MODEL_SCALE,
		} end,
})
function modifier_meepo_digger_elixir:GetEffectName()
	return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_meepo_digger_elixir:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_meepo_digger_elixir:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_as")
end

function modifier_meepo_digger_elixir:GetModifierModelScale()
	return self:GetAbility():GetSpecialValueFor("bonus_scale")
end


