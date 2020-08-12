LinkLuaModifier("modifier_leshrac_anomaly", "heroes/hero_leshrac/anomaly", 0)
LinkLuaModifier("modifier_leshrac_anomaly_passive", "heroes/hero_leshrac/anomaly", 0)

leshrac_anomaly = class({
	GetIntrinsicModifierName = function() return "modifier_leshrac_anomaly_passive" end
})

function leshrac_anomaly:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_spirit_form") then
		return "leshrac/leshrac_anomaly_spirit_form"
	else
		return "leshrac/leshrac_anomaly_body_form"
	end
end

function leshrac_anomaly:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_leshrac_anomaly", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():SpendMana(self:GetSpecialValueFor("mana_on_cast"), self)
	EmitSoundOn("", self:GetCaster())
end

modifier_leshrac_anomaly = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	} end
})

function modifier_leshrac_anomaly:OnAbilityExecuted(keys)
	local caster = self:GetCaster()
	local abilities = {}

	local cast_ability_name = keys.ability:GetName()
	local IsLeshracAbility = false

	for i = 0, 7 do
		if caster:GetAbilityByIndex(i):GetName() == cast_ability_name and caster:GetAbilityByIndex(i):GetName() ~= "leshrac_spirit_and_body" then
			IsLeshracAbility = true
		end
	end

	local IsToggle = false
	if keys.ability:GetToggleState() then
		IsToggle = true
	end

	if IsLeshracAbility and keys.unit == self:GetParent() and not IsToggle then
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)

		for _, enemy in pairs(enemies) do
			local targets = FindUnitsInRadius(caster:GetTeam(), enemy:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("stun_radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)

			local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
			if caster:HasModifier("modifier_leshrac_spirit_and_body_body_form") then
				stun_duration = stun_duration + self:GetAbility():GetSpecialValueFor("body_form_stun_duration_boost")
			end

			for _, target in pairs(targets) do
				target:AddNewModifier(caster, self:GetAbility(), "modifier_stunned", {duration = stun_duration})
			end

			local damage = self:GetAbility():GetSpecialValueFor("damage")
			if caster:HasModifier("modifier_leshrac_spirit_and_body_spirit_form") then
				damage = damage + (damage / 100 * self:GetAbility():GetSpecialValueFor("spirit_form_damage_boost_pct"))
			end

			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = damage,
				damage_type = caster:HasModifier("modifier_leshrac_spirit_and_body_spirit_form") and DAMAGE_TYPE_MAGICAL or caster:HasModifier("modifier_leshrac_spirit_and_body_body_form") and DAMAGE_TYPE_PHYSICAL
			})

			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(pfx, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("stun_radius"), 1, 1))
			ParticleManager:ReleaseParticleIndex(pfx)

			EmitSoundOnLocationWithCaster(enemy:GetAbsOrigin(), "Hero_Leshrac.Split_Earth", caster)

			break
		end
	end
end



modifier_leshrac_anomaly_passive = class({
	IsHidden = function() return false end,
	IsPurgable = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	} end
})

function modifier_leshrac_anomaly_passive:GetModifierIncomingPhysicalDamage_Percentage()
	return self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_spirit_form") and self:GetAbility():GetSpecialValueFor("spirit_form_physical_damage_reduction_pct") * -1 or 0
end

function modifier_leshrac_anomaly_passive:GetModifierIncomingSpellDamageConstant()
	return self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_body_form") and self:GetAbility():GetSpecialValueFor("body_form_mag_damage_reduction_pct") * -1 or 0
end

function modifier_leshrac_anomaly_passive:GetModifierSpellAmplify_Percentage()
	return self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_body_form") and self:GetCaster():GetStrength() / 100 * self:GetAbility():GetSpecialValueFor("body_form_str_to_spell_amp") or self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_spirit_form") and self:GetCaster():GetIntellect() / 100 * self:GetAbility():GetSpecialValueFor("spirit_form_int_to_spell_amp")
end