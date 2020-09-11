LinkLuaModifier("modifier_jakiro_dragon_flight", "heroes/hero_jakiro/dragon_flight", 0)
LinkLuaModifier("modifier_jakiro_dragon_flight_thinker", "heroes/hero_jakiro/dragon_flight", 0)
LinkLuaModifier("modifier_jakiro_dragon_flight_damage", "heroes/hero_jakiro/dragon_flight", 0)

jakiro_dragon_flight = class({})

function jakiro_dragon_flight:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jakiro_dragon_flight", {duration = self:GetSpecialValueFor("duration")})
end



modifier_jakiro_dragon_flight = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	} end,
	CheckState = function() return {
		[MODIFIER_STATE_FLYING] = true
	}
	end,
	GetEffectName = function() return "particles/units/heroes/hero_batrider/batrider_firefly.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_jakiro_dragon_flight:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_jakiro_dragon_flight:OnIntervalThink()
	local caster = self:GetCaster()
	if IsServer() then
		CreateModifierThinker(caster, self:GetAbility(), "modifier_jakiro_dragon_flight_thinker", {duration = self:GetRemainingTime()}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	end
end

function modifier_jakiro_dragon_flight:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("bonus_vision")
end

function modifier_jakiro_dragon_flight:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("bonus_vision")
end

function modifier_jakiro_dragon_flight:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct")
end



modifier_jakiro_dragon_flight_thinker = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	IsAura = function() return true end,
	GetModifierAura = function() return "modifier_jakiro_dragon_flight_damage" end
})

function modifier_jakiro_dragon_flight_thinker:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_jakiro_dragon_flight_thinker:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_jakiro_dragon_flight_thinker:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_jakiro_dragon_flight_thinker:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("damage_radius")
end



modifier_jakiro_dragon_flight_damage = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	GetEffectName = function() return "particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

if IsServer() then
	function modifier_jakiro_dragon_flight_damage:OnCreated()
		self:StartIntervalThink(1)
	end

	function modifier_jakiro_dragon_flight_damage:OnIntervalThink()
		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			ability = self:GetAbility(),
			damage = self:GetAbility():GetSpecialValueFor("damage_per_sec"),
			damage_type = self:GetAbility():GetAbilityDamageType()
		})
	end
end