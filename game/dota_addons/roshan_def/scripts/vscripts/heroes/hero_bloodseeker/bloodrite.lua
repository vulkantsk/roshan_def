LinkLuaModifier("modifier_bloodseeker_bloodrite", "heroes/hero_bloodseeker/bloodrite.lua", 0)
LinkLuaModifier("modifier_bloodseeker_bloodrite_debuff", "heroes/hero_bloodseeker/bloodrite.lua", 0)

bloodseeker_bloodrite = class({})

function bloodseeker_bloodrite:GetAOERadius() 
	return self:GetSpecialValueFor("radius") 
end

function bloodseeker_bloodrite:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("debuff_duration")
	local vPos = self:GetCursorPosition()
	local nTeamNumber = caster:GetTeam()

	CreateModifierThinker(caster, self, "modifier_bloodseeker_bloodrite", {duration = duration}, vPos, nTeamNumber, false)

	caster:EmitSound("Hero_Bloodseeker.BloodRite.Cast")
	EmitSoundOnLocationWithCaster(vPos, "Hero_bloodseeker.BloodRite", caster)
end


modifier_bloodseeker_bloodrite = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
    IsAura = function(self) return true end,
    GetAuraRadius = function(self) return self.radius end,
    GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
    GetModifierAura = function(self) return "modifier_bloodseeker_bloodrite_debuff" end,
    GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
})

function modifier_bloodseeker_bloodrite:OnCreated()
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.debuff_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( pfx, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( pfx, 1, Vector(self.radius, self.radius, self.radius) )
		ParticleManager:SetParticleControl( pfx, 3, self:GetParent():GetOrigin() )
		self:AddParticle(pfx, true, false, 3, false, false)
	end
end

function modifier_bloodseeker_bloodrite:OnDestroy()
	if IsServer() then

--		ParticleManager:DestroyParticle(self.particle, false)
	end
end

modifier_bloodseeker_bloodrite_debuff = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end,
	CheckState = function() return {[MODIFIER_STATE_SILENCED] = true} end
})

function modifier_bloodseeker_bloodrite_debuff:GetModifierPhysicalArmorBonus() 
	return self:GetAbility():GetSpecialValueFor("armor_decrease") * -1 
end