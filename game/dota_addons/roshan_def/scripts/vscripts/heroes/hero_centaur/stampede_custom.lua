LinkLuaModifier("modifier_centaur_stampede_custom", "heroes/hero_centaur/stampede_custom", LUA_MODIFIER_MOTION_NONE)

centaur_stampede_custom = class({})

function centaur_stampede_custom:OnSpellStart()
	local caster = self:GetCaster()
	local buff_duration = self:GetSpecialValueFor("buff_duration")

	EmitSoundOn("Hero_Centaur.Stampede.Cast",caster)
	caster:AddNewModifier(caster, self, "modifier_centaur_stampede_custom", {duration = buff_duration})
end

modifier_centaur_stampede_custom = class ({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	CheckState = function(self) return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}end,
})

function modifier_centaur_stampede_custom:OnCreated( data )
	local caster = self:GetCaster()

	local effect = "particles/units/heroes/hero_centaur/centaur_stampede_overhead.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_OVERHEAD_FOLLOW, caster)
	self:AddParticle(pfx, true, false, 100, true, true)

	local effect = "particles/units/heroes/hero_centaur/centaur_stampede.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	self:AddParticle(pfx, true, false, 100, true, false)
end

function modifier_centaur_stampede_custom:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("ms_bonus")
end

function modifier_centaur_stampede_custom:GetModifierIncomingPhysicalDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("dmg_resist")*(-1)
end

function modifier_centaur_stampede_custom:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("hp_regen_pct")
end
