sans_earth_crack_passive = class({})

function sans_earth_crack_passive:GetIntrinsicModifierName() return 'sans_modifier_genocide_passive' end

LinkLuaModifier("sans_modifier_genocide_passive", 'abilities/sans/sans_earth_crack_passive.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sans_aoe_spike_thinker", 'abilities/sans/sans_earth_crack_passive.lua', LUA_MODIFIER_MOTION_NONE)

sans_modifier_genocide_passive = class({})
function sans_modifier_genocide_passive:IsHidden() return true end

function sans_modifier_genocide_passive:OnCreated()
	if IsClient() then return end


	self.ability = self:GetAbility()
	self.caster = self:GetParent()
	self.radius = self.ability:GetSpecialValueFor('aoe_radius')
	self.interval = self.ability:GetSpecialValueFor('think_interval')
	self.thinkTime = self.ability:GetSpecialValueFor('think_time')
	self.effect_radius = self.ability:GetSpecialValueFor('effect_radius')
	self.impact_radius = self.ability:GetSpecialValueFor('impact_radius')
	self.damage = self.ability:GetSpecialValueFor('damage')
	self.duration_stun = self.ability:GetSpecialValueFor('duration_stun')

	self:StartIntervalThink(self.interval)

end

function sans_modifier_genocide_passive:OnIntervalThink()
	if IsClient() then return end

	local units = FindUnitsInRadius(self.caster:GetTeamNumber(),
	self.caster:GetAbsOrigin(),
	nil,
	self.radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_CLOSEST,
	false)
	for k,v in pairs(units) do
		v:AddNewModifier(self.caster, self.ability, 'sans_aoe_spike_thinker', {
			duration = self.thinkTime,
			interval = self.interval,
			effect_radius = self.effect_radius,
			impact_radius = self.impact_radius,
			damage = self.damage,
			duration_stun = self.duration_stun,
		})
	end
end

sans_aoe_spike_thinker = class({})
function sans_aoe_spike_thinker:IsDebuff() return true end
function sans_aoe_spike_thinker:IsHidden() return true end
function sans_aoe_spike_thinker:IsPermament() return true end
function sans_aoe_spike_thinker:OnCreated(data)
	if IsClient() then return end
	self.origin = self:GetParent():GetAbsOrigin()
	self.impact_radius = data.impact_radius
	self.damage = data.damage
	self.durStun = data.duration_stun

	local nfx = ParticleManager:CreateParticle('particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf', PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(nfx, 0, self.origin)
	ParticleManager:SetParticleControl(nfx, 1, Vector(data.effect_radius,0,0))
	ParticleManager:SetParticleControl(nfx, 2, Vector(data.interval,0,1))
	ParticleManager:SetParticleControl(nfx, 3, Vector(0,0,200))
	ParticleManager:SetParticleControl(nfx, 4, Vector(0,0,0))
	ParticleManager:ReleaseParticleIndex(nfx)

end


function sans_aoe_spike_thinker:OnDestroy() 
	if IsClient() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local units = FindUnitsInRadius(caster:GetTeamNumber(),
	self.origin,
	nil,
	self.impact_radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_CLOSEST,
	false)

	for k,v in pairs(units) do
		v:AddNewModifier(caster, ability, 'modifier_stunned', {
			duration = self.durStun,
		})

		ApplyDamage({
 			attacker = caster,
 			damage = self.damage,
 			victim = v,
 			damage_type = DAMAGE_TYPE_PURE,
 			ability = ability,
		})
	end

	parent:EmitSound("Hero_Leshrac.Split_Earth.Tormented")
	local nfx = ParticleManager:CreateParticle('particles/alcore_my_own_hell.vpcf', PATTACH_WORLDORIGIN, parent)
	ParticleManager:SetParticleControl(nfx, 0, self.origin)
	ParticleManager:SetParticleControl(nfx, 1, Vector(self.impact_radius,self.impact_radius,self.impact_radius))
	ParticleManager:ReleaseParticleIndex(nfx)

	GridNav:DestroyTreesAroundPoint(self.origin,self.impact_radius,true)

end