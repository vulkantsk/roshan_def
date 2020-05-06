sans_mass_telekinesis = class({})
LinkLuaModifier("modifier_sans_telekinesis", 'abilities/sans/sans_mass_telekinesis.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_telekinesis_fall", 'abilities/sans/sans_mass_telekinesis.lua', LUA_MODIFIER_MOTION_NONE)

function sans_mass_telekinesis:OnSpellStart()
	local think_time = self:GetSpecialValueFor('think_time')
	local effect_radius = self:GetSpecialValueFor('effect_radius')
	local damage = self:GetSpecialValueFor('damage')
	local duration_stun = self:GetSpecialValueFor('duration_stun')
	local impact_radius = self:GetSpecialValueFor('impact_radius')
	local lift_duration = self:GetSpecialValueFor('lift_duration')
	local vPos = self:GetCursorPosition()
	local caster = self:GetCaster()
	local ability = self

	self.pointTeleport = vPos

	local dummy = CreateUnitByName('npc_dummy_unit', vPos, false, nil, nil, DOTA_TEAM_NEUTRALS)

	local nfx = ParticleManager:CreateParticle('particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf', PATTACH_ABSORIGIN_FOLLOW, dummy)
	ParticleManager:SetParticleControl(nfx, 0, vPos)
	ParticleManager:SetParticleControl(nfx, 1, Vector(effect_radius,0,0))
	ParticleManager:SetParticleControl(nfx, 2, Vector(think_time,0,1))
	ParticleManager:SetParticleControl(nfx, 3, Vector(0,0,200))
	ParticleManager:SetParticleControl(nfx, 4, Vector(0,0,0))
	ParticleManager:ReleaseParticleIndex(nfx)

	dummy:ForceKill(false)

	local units = FindUnitsInRadius(caster:GetTeamNumber(),
	vPos,
	nil,
	impact_radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_CLOSEST,
	false)

	for k,v in pairs(units) do

		v:AddNewModifier(caster, self, 'modifier_sans_telekinesis', {
			duration = lift_duration,
		})

		ApplyDamage({
 			attacker = caster,
 			damage = damage,
 			victim = v,
 			damage_type = DAMAGE_TYPE_MAGICAL,
 			ability = ability,
		})
	end
	local nfx = self:__Drop()

	Timers:CreateTimer(lift_duration,function()
		ParticleManager:DestroyParticle(nfx, true)
		ParticleManager:ReleaseParticleIndex(nfx)
	end)

	GridNav:DestroyTreesAroundPoint(vPos,impact_radius,true)
end

function sans_mass_telekinesis:__Drop()

	local caster =  self:GetCaster()
	local point = self:GetCursorPosition()

	local drop_particle = ParticleManager:CreateParticleForTeam('particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_marker_force.vpcf', PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(drop_particle, 0, point)
	ParticleManager:SetParticleControl(drop_particle, 1, point)
	ParticleManager:SetParticleControl(drop_particle, 2, point)
	return drop_particle
end

modifier_sans_telekinesis = class({})
function modifier_sans_telekinesis:IsPurgable() return false end
function modifier_sans_telekinesis:IsBuff() return false end
function modifier_sans_telekinesis:IsDebuff() return true end
function modifier_sans_telekinesis:IsStunDebuff() return true end
function modifier_sans_telekinesis:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_sans_telekinesis:DeclareFunctions() return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION } end

function modifier_sans_telekinesis:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_sans_telekinesis:GetHeroEffectName() return 'particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_force_debuff.vpcf' end

function modifier_sans_telekinesis:CheckState()
	return {
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_FLYING] = true
}
end

function modifier_sans_telekinesis:OnCreated()
	if IsClient() then return end

	self.nfx = ParticleManager:CreateParticle('particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_force.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetOrigin())
end

function modifier_sans_telekinesis:OnDestroy()
	if IsClient() then return end

	ParticleManager:DestroyParticle(self.nfx, true)
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_sans_telekinesis_fall', {
     	duration = self:GetAbility():GetSpecialValueFor('fall_duration')
	})
end

modifier_sans_telekinesis_fall  = class({})
function modifier_sans_telekinesis_fall:OnCreated()
	if IsClient() then return end

	-- self:StartIntervalThink(0.01)
end

function modifier_sans_telekinesis_fall:OnDestroy()
	if IsClient() then return end

	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	if ability.drop_particle ~= nil then
		ParticleManager:DestroyParticle(ability.drop_particle, true)
	end
	local origin = target:GetAbsOrigin()
	local particle = ParticleManager:CreateParticleForTeam('particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_land_force.vpcf', PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(particle, 0, origin)
	ParticleManager:SetParticleControl(particle, 1, origin)
	ParticleManager:SetParticleControl(particle, 2, origin)
	ParticleManager:ReleaseParticleIndex(particle)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), ability.pointTeleport, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
	for i,unit in ipairs(units) do
		unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end
	EmitSoundOn('Hero_Rubick.Telekinesis.Stun', target)
	
	FindClearSpaceForUnit(target, ability.pointTeleport, false)

end
