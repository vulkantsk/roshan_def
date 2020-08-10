LinkLuaModifier("modifier_bloodseeker_blood_strength", "heroes/hero_bloodseeker/blood_strength.lua", 0)
LinkLuaModifier("modifier_bloodseeker_blood_strength_buff", "heroes/hero_bloodseeker/blood_strength.lua", 0)

bloodseeker_blood_strength = class({GetIntrinsicModifierName = function() return "modifier_bloodseeker_blood_strength" end})

function bloodseeker_blood_strength:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:ModifyHealth(1, self, false, 0)
	caster:AddNewModifier(caster, self, "modifier_bloodseeker_blood_strength_buff", {duration = duration})
end

modifier_bloodseeker_blood_strength = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, 
		MODIFIER_EVENT_ON_DEATH} end
})

function modifier_bloodseeker_blood_strength:OnDeath(keys)
	if keys.attacker == self:GetParent() then
		self:IncrementStackCount()
	end
	self:GetParent():CalculateStatBonus()
end

function modifier_bloodseeker_blood_strength:GetModifierBonusStats_Agility()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("agi_per_kill")
end

modifier_bloodseeker_blood_strength_buff = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_MIN_HEALTH} end
})

function modifier_bloodseeker_blood_strength_buff:GetMinHealth() return 1 end