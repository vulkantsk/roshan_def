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
snapfire_mortimer_kiss = class({})
LinkLuaModifier( "modifier_snapfire_mortimer_kiss", "heroes/hero_snapfire/mortimer_kiss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_mortimer_kiss_passive", "heroes/hero_snapfire/mortimer_kiss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_mortimer_kiss_thinker", "heroes/hero_snapfire/mortimer_kiss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_mortimer_kiss_debuff", "heroes/hero_snapfire/mortimer_kiss", LUA_MODIFIER_MOTION_NONE )


function snapfire_mortimer_kiss:GetIntrinsicModifierName()
    return "modifier_snapfire_mortimer_kiss_passive"
end

--------------------------------------------------------------------------------
-- Projectile
function snapfire_mortimer_kiss:OnProjectileHit( target, location )
    if not target then return end

    -- load data
    local damage = self:GetSpecialValueFor( "damage_per_impact" )
    local duration = self:GetSpecialValueFor( "burn_ground_duration" )
    local impact_radius = self:GetSpecialValueFor( "impact_radius" )
    local vision = self:GetSpecialValueFor( "projectile_vision" )

    -- precache damage
    local damageTable = {
        -- victim = target,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
    }

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),   -- int, your team number
        location,   -- point, center point
        nil,    -- handle, cacheUnit. (not known)
        impact_radius,  -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,    -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        0,  -- int, flag filter
        0,  -- int, order filter
        false   -- bool, can grow cache
    )

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage(damageTable)
    end

    -- start aura on thinker
    target:AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_snapfire_mortimer_kiss_thinker", -- modifier name
        {
            duration = duration,
            slow = 1,
        } -- kv
    )

    -- destroy trees
--    GridNav:DestroyTreesAroundPoint( location, impact_radius, true )

    -- create Vision
    AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision, duration, false )

    -- play effects
    self:PlayEffects( target:GetOrigin() )
end

--------------------------------------------------------------------------------
function snapfire_mortimer_kiss:PlayEffects( loc )
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
    local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
    local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 3, loc )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, loc )
    ParticleManager:SetParticleControl( effect_cast, 1, loc )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
    EmitSoundOnLocationWithCaster( loc, sound_location, self:GetCaster() )
end

modifier_snapfire_mortimer_kiss_passive = class({
    IsHidden = function(self) return false end,
    DeclareFunctions = function(self) return {
        MODIFIER_EVENT_ON_ATTACK
    }end,
})

function modifier_snapfire_mortimer_kiss_passive:OnCreated()
    local ability =self:GetAbility()
    self.caster = self:GetCaster()
    self.trigger_count = ability:GetSpecialValueFor("trigger_count")
    self.trigger_radius = ability:GetSpecialValueFor("trigger_radius")

    self.travel_time = ability:GetSpecialValueFor( "travel_time" )
   
    self.projectile_speed = ability:GetSpecialValueFor( "projectile_speed" )
    local projectile_vision = ability:GetSpecialValueFor( "projectile_vision" )
    
    self.turn_rate = ability:GetSpecialValueFor( "turn_rate" )

    if not IsServer() then return end

    -- load data
    local projectile_name = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf"
    local projectile_start_radius = 0
    local projectile_end_radius = 0

    -- precache projectile
    self.info = {
        -- Target = target,
        Source = self.caster,
        Ability = ability,    
        
        EffectName = projectile_name,
        iMoveSpeed = self.projectile_speed,
        bDodgeable = false,                           -- Optional
    
        vSourceLoc = self.caster:GetOrigin(),                -- Optional (HOW)
        
        bDrawsOnMinimap = false,                          -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bProvidesVision = true,                           -- Optional
        iVisionRadius = projectile_vision,                              -- Optional
        iVisionTeamNumber = self.caster:GetTeamNumber()        -- Optional
    }

end

function modifier_snapfire_mortimer_kiss_passive:OnRefresh()
    self:OnCreated()
end

function modifier_snapfire_mortimer_kiss_passive:OnAttack(data)
    local target = data.target
    local attacker = data.attacker 
    local caster = self.caster
    if attacker == caster and caster:IsAlive()  then
        local ability = self:GetAbility()
        local point = caster:GetAbsOrigin()
        if self:GetStackCount() >= self.trigger_count then
            local keys = {flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE} 
            local enemies = caster:FindEnemyUnitsInRadius(point, self.trigger_radius, keys)
            local enemy = enemies[RandomInt(1, #enemies)]
            if enemy then
                self:SetStackCount(0)
                local enemy_point = enemy:GetAbsOrigin()
                local thinker = CreateModifierThinker(
                    caster, -- player source
                    ability, -- ability source
                    "modifier_snapfire_mortimer_kiss_thinker", -- modifier name
                    { travel_time = self.travel_time }, -- kv
                    enemy_point,
                    caster:GetTeam(),
                    false
                )

                -- set projectile
                self.info.iMoveSpeed = (point - enemy_point):Length2D()/self.travel_time
                self.info.Target = thinker
                caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 1)

                -- launch projectile
                ProjectileManager:CreateTrackingProjectile( self.info )

                -- create FOW
--                AddFOWViewer( self:GetParent():GetTeamNumber(), thinker:GetOrigin(), 100, 1, false )

                -- play sound
                local sound_cast = "Hero_Snapfire.MortimerBlob.Launch"
                EmitSoundOn( sound_cast, self:GetParent() )
            end
        else
            self:IncrementStackCount()
        end
    end
end

modifier_snapfire_mortimer_kiss_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_snapfire_mortimer_kiss_debuff:IsHidden()
    return false
end

function modifier_snapfire_mortimer_kiss_debuff:IsDebuff()
    return true
end

function modifier_snapfire_mortimer_kiss_debuff:IsStunDebuff()
    return false
end

function modifier_snapfire_mortimer_kiss_debuff:IsPurgable()
    return true
end

function modifier_snapfire_mortimer_kiss_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_mortimer_kiss_debuff:OnCreated( kv )
    -- references
    self.slow = -self:GetAbility():GetSpecialValueFor( "move_slow_pct" )
    self.dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )
    local interval = self:GetAbility():GetSpecialValueFor( "burn_interval" )

    if not IsServer() then return end

    -- precache damage
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.dps*interval,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(), --Optional.
    }

    -- Start interval
    self:StartIntervalThink( interval )
    self:OnIntervalThink()
end

function modifier_snapfire_mortimer_kiss_debuff:OnRefresh( kv )
    
end

function modifier_snapfire_mortimer_kiss_debuff:OnRemoved()
end

function modifier_snapfire_mortimer_kiss_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_snapfire_mortimer_kiss_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_snapfire_mortimer_kiss_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_snapfire_mortimer_kiss_debuff:OnIntervalThink()
    -- apply damage
    ApplyDamage( self.damageTable )

    -- play overhead
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_snapfire_mortimer_kiss_debuff:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function modifier_snapfire_mortimer_kiss_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_snapfire_mortimer_kiss_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_snapfire_mortimer_kiss_debuff:StatusEffectPriority()
    return MODIFIER_PRIORITY_NORMAL
end

modifier_snapfire_mortimer_kiss_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_mortimer_kiss_thinker:OnCreated( kv )
    -- references
    self.travel_time = self:GetAbility():GetSpecialValueFor( "travel_time" )
    self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
    self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

    if not IsServer() then return end

    -- dont start aura right off
    self.start = false

    -- create aoe finder particle
    self:PlayEffects( kv.travel_time )
end

function modifier_snapfire_mortimer_kiss_thinker:OnRefresh( kv )
     self.travel_time = self:GetAbility():GetSpecialValueFor( "travel_time" )
    self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
    self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

    if not IsServer() then return end

    -- start aura
    self.start = true

    -- stop aoe finder particle
    self:StopEffects()
end

function modifier_snapfire_mortimer_kiss_thinker:OnRemoved()
end

function modifier_snapfire_mortimer_kiss_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_snapfire_mortimer_kiss_thinker:IsAura()
    return self.start
end

function modifier_snapfire_mortimer_kiss_thinker:GetModifierAura()
    return "modifier_snapfire_mortimer_kiss_debuff"
end

function modifier_snapfire_mortimer_kiss_thinker:GetAuraRadius()
    return self.radius
end

function modifier_snapfire_mortimer_kiss_thinker:GetAuraDuration()
    return self.linger
end

function modifier_snapfire_mortimer_kiss_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_snapfire_mortimer_kiss_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_snapfire_mortimer_kiss_thinker:PlayEffects( time )
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

    -- Create Particle
    self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.travel_time/time) ) )
    ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end

function modifier_snapfire_mortimer_kiss_thinker:StopEffects()
    ParticleManager:DestroyParticle( self.effect_cast, true )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )
end