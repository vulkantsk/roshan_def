LinkLuaModifier("modifier_leshrac_ethereal_flame", "heroes/hero_leshrac/ethereal_flame", 0)

leshrac_ethereal_flame = class({})

function leshrac_ethereal_flame:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_spirit_form") then
		return "leshrac/leshrac_ethereal_flame_spirit_form"
	else
		return "leshrac/leshrac_ethereal_flame_body_form"
	end
end

function leshrac_ethereal_flame:OnToggle()
	local caster = self:GetCaster()

	if not caster:HasModifier("modifier_leshrac_ethereal_flame") then
		caster:AddNewModifier(caster, self, "modifier_leshrac_ethereal_flame", nil)
	else
		caster:RemoveModifierByName("modifier_leshrac_ethereal_flame")
	end
	if self:GetToggleState() then
		EmitSoundOn("Hero_Leshrac.Pulse_Nova", caster)
	else
		StopSoundOn("Hero_Leshrac.Pulse_Nova", caster)
	end
end

modifier_leshrac_ethereal_flame = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	GetEffectName = function() return "particles/units/heroes/hero_leshrac/leshrac_pulse_nova_ambient.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_leshrac_ethereal_flame:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
	self:OnIntervalThink()
	self:GetCaster():GiveMana(self:GetAbility():GetSpecialValueFor("mana_spend_per_sec"))
end

function modifier_leshrac_ethereal_flame:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)

	local damage = self:GetAbility():GetSpecialValueFor("damage")
	if caster:HasModifier("modifier_leshrac_spirit_and_body_spirit_form") then
		damage = damage + (damage / 100 * self:GetAbility():GetSpecialValueFor("spirit_form_damage_boost_pct"))
	end

	local heal = self:GetAbility():GetSpecialValueFor("damage_to_heal_pct")
	if caster:HasModifier("modifier_leshrac_spirit_and_body_body_form") then
		heal = heal + self:GetAbility():GetSpecialValueFor("body_form_heal_boost")
	end

	for _, enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = caster,
			ability = self:GetAbility(),
			damage = damage,
			damage_type = caster:HasModifier("modifier_leshrac_spirit_and_body_spirit_form") and DAMAGE_TYPE_MAGICAL or caster:HasModifier("modifier_leshrac_spirit_and_body_body_form") and DAMAGE_TYPE_PHYSICAL
		})

		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(pfx, 0, enemy:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(1, 0, 0))
		ParticleManager:ReleaseParticleIndex(pfx)
	end

	if #enemies > 0 then
		caster:Heal(heal, caster)
	end

	caster:SpendMana(self:GetAbility():GetSpecialValueFor("mana_spend_per_sec"), self:GetAbility())

	if caster:GetMana() < self:GetAbility():GetSpecialValueFor("mana_spend_per_sec") then
		caster:CastAbilityToggle(self:GetAbility(), -1)
	end
end