LinkLuaModifier("modifier_leshrac_spirit_and_body", "heroes/hero_leshrac/spirit_and_body", 0)
LinkLuaModifier("modifier_leshrac_spirit_and_body_spirit_form", "heroes/hero_leshrac/spirit_and_body", 0)
LinkLuaModifier("modifier_leshrac_spirit_and_body_body_form", "heroes/hero_leshrac/spirit_and_body", 0)

leshrac_spirit_and_body = class({
	GetIntrinsicModifierName = function() return "modifier_leshrac_spirit_and_body" end
})

function leshrac_spirit_and_body:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_leshrac_spirit_and_body_spirit_form") then
		return "leshrac/leshrac_spirit_and_body_form_spirit_form"
	else
		return "leshrac/leshrac_spirit_and_body_form_body_form"
	end
end

function leshrac_spirit_and_body:OnToggle()
	local caster = self:GetCaster()

	local spirit_abilities = {
		"leshrac_breaking_the_veil_spirit_form",
		"leshrac_chain_lightning_spirit_form"
	}
	local body_abilities = {
		"leshrac_breaking_the_veil_body_form",
		"leshrac_chain_lightning_body_form"
	}

	if caster:HasModifier("modifier_leshrac_spirit_and_body_spirit_form") then
		caster:RemoveModifierByName("modifier_leshrac_spirit_and_body_spirit_form")
		caster:AddNewModifier(caster, self, "modifier_leshrac_spirit_and_body_body_form", nil)

		caster:SwapAbilities("leshrac_breaking_the_veil_spirit_form", "leshrac_breaking_the_veil_body_form", false, true)
		caster:SwapAbilities("leshrac_chain_lightning_spirit_form", "leshrac_chain_lightning_body_form", false, true)


		EmitSoundOn("Hero_Warlock.ShadowWordCastGood", caster)
	else
		caster:RemoveModifierByName("modifier_leshrac_spirit_and_body_body_form")
		caster:AddNewModifier(caster, self, "modifier_leshrac_spirit_and_body_spirit_form", nil)

		caster:SwapAbilities("leshrac_breaking_the_veil_body_form", "leshrac_breaking_the_veil_spirit_form", false, true)
		caster:SwapAbilities("leshrac_chain_lightning_body_form", "leshrac_chain_lightning_spirit_form", false, true)

		EmitSoundOn("DOTA_Item.GhostScepter.Activate", caster)
	end

	self:UseResources(false, false, true)
end

modifier_leshrac_spirit_and_body = class({
	IsPurgable = function() return false end,
	IsHidden = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	} end
})



function modifier_leshrac_spirit_and_body:OnTakeDamage(keys)
	local parent = self:GetParent()

	if keys.unit == parent and keys.damage > parent:GetHealth() and self:GetAbility():IsActivated() then
		parent:Heal(parent:GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("heal_pct"), parent)
		self:GetCaster():CastAbilityToggle(self:GetAbility(), -1)
		self:GetAbility():SetActivated(false)
		self:StartIntervalThink(self:GetSpecialValueFor("disable_time"))

		EmitSoundOn("Hero_Oracle.FalsePromise.Damaged", self:GetParent())

		local pfx = ParticleManager:CreateParticle("particles/econ/items/death_prophet/death_prophet_ti9/death_prophet_silence_ti9.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(60, 0, 0))
		ParticleManager:ReleaseParticleIndex(pfx)

		self.pfx2 = ParticleManager:CreateParticle("particles/items4_fx/spirit_vessel_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(self.pfx2, 0, self:GetCaster():GetAbsOrigin())
		self:AddParticle(self.pfx2, false, false, -1, true, false)

	end
end

if IsServer() then
	function modifier_leshrac_spirit_and_body:OnCreated()
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_leshrac_spirit_and_body_body_form", nil)
	end

	function modifier_leshrac_spirit_and_body:OnIntervalThink()
		self:GetAbility():SetActivated(true)
		self:StartIntervalThink(-1)
		ParticleManager:DestroyParticle(self.pfx2, false)
	end
end

function modifier_leshrac_spirit_and_body:GetDisableHealing()
	--return not self:GetAbility():IsActivated() and 1 or 0
end

modifier_leshrac_spirit_and_body_spirit_form = class({
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_ghost.vpcf" end
})
modifier_leshrac_spirit_and_body_body_form = class({
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end
})