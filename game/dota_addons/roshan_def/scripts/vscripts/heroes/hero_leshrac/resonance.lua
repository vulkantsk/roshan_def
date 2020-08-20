LinkLuaModifier("modifier_leshrac_resonance", "heroes/hero_leshrac/resonance", 0)

leshrac_resonance = class({
	GetIntrinsicModifierName = function() return "modifier_leshrac_resonance" end
})

modifier_leshrac_resonance = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	} end
})

function modifier_leshrac_resonance:OnTakeDamage(keys)
	if keys.inflictor ~= (nil or self:GetCaster():FindAbilityByName("leshrac_resonance")) and keys.unit and keys.attacker == self:GetParent() and keys.damage_type == DAMAGE_TYPE_MAGICAL then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("magic_crit_chance")) then
			local damage = (keys.damage * (self:GetAbility():GetSpecialValueFor("magic_crit_mult_pct") / 100))

			SendOverheadEventMessage(keys.unit, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.unit, math.floor(damage), nil)

			ApplyDamage({
				victim = keys.unit,
				attacker = self:GetParent(),
				ability = self:GetAbility(),
				damage = damage,
				damage_type = keys.damage_type,
				damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
			})
		end
	end
end