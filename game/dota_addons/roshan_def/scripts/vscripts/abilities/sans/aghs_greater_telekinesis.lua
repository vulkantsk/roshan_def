aghs_greater_telekinesis = class({})

function aghs_greater_telekinesis:OnSpellStart()
	local radius = self:GetSpecialValueFor('radius')
	local caster = self:GetCaster()
	local vPos = caster:GetOrigin()
	local lift_duration = self:GetSpecialValueFor('lift_duration')
	local units = FindUnitsInRadius(caster:GetTeamNumber(),
	vPos,
	nil,
	FIND_UNITS_EVERYWHERE,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_CLOSEST,
	false)

	for __,unit in pairs(units) do
		unit:AddNewModifier(caster, self, 'modifier_sans_telekinesis_global', {
			duration = lift_duration,
		})
		EmitSoundOn('Hero_Rubick.Telekinesis.Target', unit)
	end
end
LinkLuaModifier("modifier_sans_telekinesis_global", 'abilities/sans/aghs_greater_telekinesis.lua', LUA_MODIFIER_MOTION_NONE)
modifier_sans_telekinesis_global = class({})
function modifier_sans_telekinesis_global:IsPurgable() return false end
function modifier_sans_telekinesis_global:IsBuff() return false end
function modifier_sans_telekinesis_global:IsDebuff() return true end
function modifier_sans_telekinesis_global:IsStunDebuff() return true end
function modifier_sans_telekinesis_global:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_sans_telekinesis_global:DeclareFunctions() return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION } end

function modifier_sans_telekinesis_global:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_sans_telekinesis_global:GetHeroEffectName() return 'particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_force_debuff.vpcf' end

function modifier_sans_telekinesis_global:CheckState()
	return {
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_FLYING] = true
}
end

function modifier_sans_telekinesis_global:OnCreated()
	if IsClient() then return end

	self.nfx = ParticleManager:CreateParticle('particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_force.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetOrigin())

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local telekinesis = ability
	local point = ability:GetCursorPosition()
	self.point = point
	if self.drop_particle  then
		ParticleManager:DestroyParticle(self.drop_particle, true)
	end
	self.drop_particle = ParticleManager:CreateParticleForTeam('particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_marker_force.vpcf', PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(self.drop_particle, 0, point)
	ParticleManager:SetParticleControl(self.drop_particle, 1, point)
	ParticleManager:SetParticleControl(self.drop_particle, 2, point)
end

function modifier_sans_telekinesis_global:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	FindClearSpaceForUnit( parent, self.point, true )
	ParticleManager:DestroyParticle(self.drop_particle, true)
	ParticleManager:DestroyParticle(self.nfx, true)
	ParticleManager:ReleaseParticleIndex(self.drop_particle)
	ParticleManager:ReleaseParticleIndex(self.nfx)
end
