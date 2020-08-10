LinkLuaModifier("modifier_bloodseeker_bloodrage_custom", "heroes/hero_bloodseeker/bloodrage", 0)

bloodseeker_bloodrage_custom = class({})

function bloodseeker_bloodrage_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	target:AddNewModifier(caster, self, "modifier_bloodseeker_bloodrage_custom", {duration = duration})
	target:EmitSound("hero_bloodseeker.bloodRage")
end

modifier_bloodseeker_bloodrage_custom = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, 
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	} end
})

function modifier_bloodseeker_bloodrage_custom:OnCreated()
	local ability = self:GetAbility()
	self.bonus_out_dmg = ability:GetSpecialValueFor("bonus_out_dmg")
	self.bonus_self_dmg = ability:GetSpecialValueFor("bonus_self_dmg")
end

function modifier_bloodseeker_bloodrage_custom:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end

function modifier_bloodseeker_bloodrage_custom:OnRefresh()
	self:OnCreated()
end 

function modifier_bloodseeker_bloodrage_custom:GetModifierTotalDamageOutgoing_Percentage() return self.bonus_self_dmg
end

function modifier_bloodseeker_bloodrage_custom:GetModifierIncomingDamage_Percentage() return self.bonus_self_dmg 
end