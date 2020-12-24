LinkLuaModifier("modifier_treant_recover_passive", "abilities/treant_recover", 0)
LinkLuaModifier("modifier_treant_recover_effect", "abilities/treant_recover", 0)

treant_recover = class({
	GetIntrinsicModifierName = function() return "modifier_treant_recover_passive" end
})

modifier_treant_recover_passive = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	IsDebuff = function() return false end,
	IsBuff = function() return true end,
	RemoveOnDeath = function() return false end,
	CheckState = function() return {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true
	} end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	} end,
	GetMinHealth = function() return 1 end
})

function modifier_treant_recover_passive:OnCreated()
	if not IsServer() then return end
	self:GetCaster():SetRenderColor(0, 128, 0)
end

function modifier_treant_recover_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()

	if keys.unit ~= caster then
		return
	end

	if caster:GetHealth() <= 1 then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_treant_recover_effect", { duration = self:GetAbility():GetSpecialValueFor("recover_duration")})
	end
end

modifier_treant_recover_effect = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	IsDebuff = function() return false end,
	IsBuff = function() return true end,
	RemoveOnDeath = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	  	MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	} end,
	CheckState = function() return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true
	} end,
	GetModifierModelChange = function() return "models/props_tree/dire_tree003.vmdl" end,
	GetModifierModelScale = function() return 50 end,
	GetEffectName = function() return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf" end
})

function modifier_treant_recover_effect:OnCreated()
	EmitSoundOn("Hero_Treant.Overgrowth.Cast", self:GetCaster())
end

function modifier_treant_recover_effect:GetModifierHealthRegenPercentage()
	return 100 / self:GetAbility():GetSpecialValueFor("recover_duration")
end