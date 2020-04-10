LinkLuaModifier("modifier_meepo_earth_power", "heroes/hero_meepo/earth_power", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_earth_power_buff", "heroes/hero_meepo/earth_power", LUA_MODIFIER_MOTION_NONE)

meepo_earth_power = class({})

function meepo_earth_power:OnSpellStart()
	local caster = self:GetCaster()
	local buff_duration = self:GetSpecialValueFor("buff_duration")

	caster:EmitSound("meepo_meepo_rare_0"..RandomInt(1, 4))
	caster:AddNewModifier(caster, self, "modifier_meepo_earth_power_buff", {duration = buff_duration})
end

function meepo_earth_power:GetIntrinsicModifierName()
	return "modifier_meepo_earth_power"
end
--------------------------------------------------------
------------------------------------------------------------
modifier_meepo_earth_power = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		} end,
})

function modifier_meepo_earth_power:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_meepo_earth_power:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local bonus_str_pct = ability:GetSpecialValueFor("bonus_str_pct")/100
	local stack_count = self:GetStackCount()
	local strength = caster:GetStrength() - stack_count
	local str_bonus = strength * bonus_str_pct

	self:SetStackCount(str_bonus)
end

function modifier_meepo_earth_power:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

modifier_meepo_earth_power_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		} end,
})

function modifier_meepo_earth_power_buff:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_meepo_earth_power_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_meepo_earth_power_buff:StatusEffectPriority()
	return 100
end


