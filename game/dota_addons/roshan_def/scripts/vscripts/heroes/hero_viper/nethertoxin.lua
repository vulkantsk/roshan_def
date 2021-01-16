 LinkLuaModifier("modifier_viper_nethertoxin_custom", "heroes/hero_viper/nethertoxin", 0)

 -- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
viper_nethertoxin_custom = class({})

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function viper_nethertoxin_custom:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function viper_nethertoxin_custom:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local vector = point-caster:GetOrigin()

	-- load data
	local projectile_name = ""
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local projectile_distance = vector:Length2D()
	local projectile_direction = vector
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_NONE,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = 0,
	    fEndRadius = 0,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- play effects
	self:PlayEffects( point )
end
--------------------------------------------------------------------------------
-- Projectile
function viper_nethertoxin_custom:OnProjectileHit( target, location )
	-- should be no target
	if target then return false end

	-- references
	local duration = self:GetSpecialValueFor( "duration" )

	-- create thinker
	CreateModifierThinker(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_viper_nethertoxin_custom", -- modifier name
		{ duration = duration }, -- kv
		location,
		self:GetCaster():GetTeamNumber(),
		false
	)
end

------------------------------------------------------------------------------
function viper_nethertoxin_custom:PlayEffects( point )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_viper/viper_nethertoxin_proj.vpcf"
	local sound_cast = "Hero_Viper.Nethertoxin.Cast"

	-- Get Data
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, point )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

modifier_viper_nethertoxin_custom = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_viper_nethertoxin_custom:IsHidden()
	return false
end

function modifier_viper_nethertoxin_custom:IsDebuff()
	return true
end

function modifier_viper_nethertoxin_custom:IsStunDebuff()
	return false
end

function modifier_viper_nethertoxin_custom:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_viper_nethertoxin_custom:OnCreated( kv )
	-- references
	self.max_damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
	self.max_duration = self:GetAbility():GetSpecialValueFor( "max_duration" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	self.owner = kv.isProvidedByAura~=1

	if not IsServer() then return end

	if not self.owner then
		-- precache damage
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}
		-- ApplyDamage(damageTable)

		-- Start interval
		self:StartIntervalThink( 1 )
	else
		self:PlayEffects()
	end

end

function modifier_viper_nethertoxin_custom:OnRefresh( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
--	self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resistance" )
end

function modifier_viper_nethertoxin_custom:OnRemoved()
end

function modifier_viper_nethertoxin_custom:OnDestroy()
	if not IsServer() then return end
	if not self.owner then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_viper_nethertoxin_custom:DeclareFunctions()
	local funcs = {
--		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}

	return funcs
end

function modifier_viper_nethertoxin_custom:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_viper_nethertoxin_custom:CheckState()
	local state = {
--		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_viper_nethertoxin_custom:OnIntervalThink()
	-- Apply damage
	if self:GetStackCount() ~= self.max_duration then
		self:IncrementStackCount()
	end
	self.damageTable.damage = (self:GetStackCount() + 1)/self.max_duration*self.max_damage
	ApplyDamage( self.damageTable )
	-- Play effects
	local sound_cast = "Hero_Viper.NetherToxin.Damage"
	EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_viper_nethertoxin_custom:IsAura()
	return self.owner
end

function modifier_viper_nethertoxin_custom:GetModifierAura()
	return "modifier_viper_nethertoxin_custom"
end

function modifier_viper_nethertoxin_custom:GetAuraRadius()
	return self.radius
end

function modifier_viper_nethertoxin_custom:GetAuraDuration()
	return 0.5
end

function modifier_viper_nethertoxin_custom:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_viper_nethertoxin_custom:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_viper_nethertoxin_custom:GetEffectName()
	if not self.owner then
		return "particles/units/heroes/hero_viper/viper_nethertoxin_debuff.vpcf"
	end
end

function modifier_viper_nethertoxin_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_viper_nethertoxin_custom:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_viper/viper_nethertoxin.vpcf"
	local sound_cast = "Hero_Viper.NetherToxin"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end