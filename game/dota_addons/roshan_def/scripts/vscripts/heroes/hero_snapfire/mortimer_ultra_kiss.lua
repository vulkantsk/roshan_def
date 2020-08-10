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
snapfire_mortimer_ultra_kiss = class({})
LinkLuaModifier( "modifier_snapfire_mortimer_ultra_kiss", "heroes/hero_snapfire/mortimer_ultra_kiss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_mortimer_ultra_kiss_thinker", "heroes/hero_snapfire/mortimer_ultra_kiss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_mortimer_ultra_kiss_debuff", "heroes/hero_snapfire/mortimer_ultra_kiss", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function snapfire_mortimer_ultra_kiss:GetAOERadius()
    return self:GetSpecialValueFor( "impact_radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function snapfire_mortimer_ultra_kiss:OnAbilityPhaseStart()
    local index = RandomInt(1, 24)
    if index < 10 then
        index = "0"..index
    end
    self:GetCaster():EmitSound("snapfire_snapfire_ability4_"..index)   

    return true
end
function snapfire_mortimer_ultra_kiss:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    -- load data
    local duration = self:GetDuration()
    local mana_convert_damage = self:GetSpecialValueFor("mana_convert_damage")
    local projectile_damage = caster:GetMana()*mana_convert_damage/100
    caster:SetMana(0) 

    -- add modifier
    caster:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_snapfire_mortimer_ultra_kiss", -- modifier name
        {
            duration = 0.1,
            projectile_damage = projectile_damage,
            pos_x = point.x,
            pos_y = point.y,
        } -- kv
    )

end

--------------------------------------------------------------------------------
-- Projectile
function snapfire_mortimer_ultra_kiss:OnProjectileHit( target, location )
    if not target then return end

    -- load data
    local damage_per_impact = self:GetSpecialValueFor("damage_per_impact")
    local damage = target.projectile_damage + damage_per_impact
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
        "modifier_snapfire_mortimer_ultra_kiss_thinker", -- modifier name
        {
            duration = duration,
            slow = 1,
        } -- kv
    )

    -- destroy trees
    GridNav:DestroyTreesAroundPoint( location, impact_radius, true )

    -- create Vision
    AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision, duration, false )

    -- play effects
    self:PlayEffects( target:GetOrigin() )
end

--------------------------------------------------------------------------------
function snapfire_mortimer_ultra_kiss:PlayEffects( loc )
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

modifier_snapfire_mortimer_ultra_kiss = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_snapfire_mortimer_ultra_kiss:IsHidden()
    return false
end

function modifier_snapfire_mortimer_ultra_kiss:IsDebuff()
    return false
end

function modifier_snapfire_mortimer_ultra_kiss:IsStunDebuff()
    return false
end

function modifier_snapfire_mortimer_ultra_kiss:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_mortimer_ultra_kiss:OnCreated( kv )
    -- references
    self.min_range = self:GetAbility():GetSpecialValueFor( "min_range" )
    self.max_range = self:GetAbility():GetCastRange( Vector(0,0,0), nil )
    self.range = self.max_range-self.min_range
    
    self.min_travel = self:GetAbility():GetSpecialValueFor( "min_lob_travel_time" )
    self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
    self.travel_range = self.max_travel-self.min_travel
    
    self.projectile_speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" )
    self.projectile_damage = kv.projectile_damage
    local projectile_vision = self:GetAbility():GetSpecialValueFor( "projectile_vision" )
    
    self.turn_rate = self:GetAbility():GetSpecialValueFor( "turn_rate" )
    self.impact_radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )

    if not IsServer() then return end

    -- load data
    local interval = self:GetAbility():GetDuration()/self:GetAbility():GetSpecialValueFor( "projectile_count" ) + 0.01 -- so it only have 8 projectiles instead of 9
    self:SetValidTarget( Vector( kv.pos_x, kv.pos_y, 0 ) )
    local projectile_name = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf"
    local projectile_start_radius = 0
    local projectile_end_radius = 0

    -- precache projectile
    self.info = {
        -- Target = target,
        Source = self:GetCaster(),
        Ability = self:GetAbility(),
        
        EffectName = projectile_name,
        iMoveSpeed = self.projectile_speed,
        bDodgeable = false,                           -- Optional
    
        vSourceLoc = self:GetCaster():GetOrigin(),                -- Optional (HOW)
        
        bDrawsOnMinimap = false,                          -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bProvidesVision = true,                           -- Optional
        iVisionRadius = projectile_vision,                              -- Optional
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
    }
    -- Start interval
--    self:StartIntervalThink( interval )
    self:OnIntervalThink()
    
end

function modifier_snapfire_mortimer_ultra_kiss:OnRefresh( kv )
    
end

function modifier_snapfire_mortimer_ultra_kiss:OnRemoved()
end

function modifier_snapfire_mortimer_ultra_kiss:OnDestroy()
    local index = RandomInt(1, 12)
    if index < 10 then
        index = "0"..index
    end
    self:GetCaster():EmitSound("snapfire_snapfire_ability_stop_"..index)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_snapfire_mortimer_ultra_kiss:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER,

        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

    return funcs
end

function modifier_snapfire_mortimer_ultra_kiss:OnOrder( params )
    if params.unit~=self:GetParent() then return end

    -- right click, switch position
    if  params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        self:SetValidTarget( params.new_pos )
    elseif 
        params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
        params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
    then
        self:SetValidTarget( params.target:GetOrigin() )

    -- stop or hold
    elseif 
        params.order_type==DOTA_UNIT_ORDER_STOP or
        params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
    then
        self:Destroy()
    end
end

function modifier_snapfire_mortimer_ultra_kiss:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_snapfire_mortimer_ultra_kiss:GetModifierTurnRate_Percentage()
    return -self.turn_rate
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_snapfire_mortimer_ultra_kiss:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_snapfire_mortimer_ultra_kiss:OnIntervalThink()
    -- create target thinker
    local thinker = CreateModifierThinker(
        self:GetParent(), -- player source
        self:GetAbility(), -- ability source
        "modifier_snapfire_mortimer_ultra_kiss_thinker", -- modifier name
        { travel_time = self.travel_time }, -- kv
        self.target,
        self:GetParent():GetTeamNumber(),
        false
    )

    -- set projectile
    self.info.iMoveSpeed = self.vector:Length2D()/self.travel_time
    self.info.Target = thinker
    thinker.projectile_damage = self.projectile_damage    
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 1)

    -- launch projectile
    ProjectileManager:CreateTrackingProjectile( self.info )

    -- create FOW
    AddFOWViewer( self:GetParent():GetTeamNumber(), thinker:GetOrigin(), self.impact_radius, 1, false )

    -- play sound
    local sound_cast = "Hero_Snapfire.MortimerBlob.Launch"
    EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Helper
function modifier_snapfire_mortimer_ultra_kiss:SetValidTarget( location )
    local origin = self:GetParent():GetOrigin()
    local vec = location-origin
    local direction = vec
    direction.z = 0
    direction = direction:Normalized()

    if vec:Length2D()<self.min_range then
        vec = direction * self.min_range
    elseif vec:Length2D()>self.max_range then
        vec = direction * self.max_range
    end

    self.target = GetGroundPosition( origin + vec, nil )
    self.vector = vec
    self.travel_time = (vec:Length2D()-self.min_range)/self.range * self.travel_range + self.min_travel
end

modifier_snapfire_mortimer_ultra_kiss_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_snapfire_mortimer_ultra_kiss_debuff:IsHidden()
    return false
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:IsDebuff()
    return true
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:IsStunDebuff()
    return false
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_mortimer_ultra_kiss_debuff:OnCreated( kv )
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

function modifier_snapfire_mortimer_ultra_kiss_debuff:OnRefresh( kv )
    
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:OnRemoved()
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_snapfire_mortimer_ultra_kiss_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_snapfire_mortimer_ultra_kiss_debuff:OnIntervalThink()
    -- apply damage
    ApplyDamage( self.damageTable )

    -- play overhead
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_snapfire_mortimer_ultra_kiss_debuff:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_snapfire_mortimer_ultra_kiss_debuff:StatusEffectPriority()
    return MODIFIER_PRIORITY_NORMAL
end

modifier_snapfire_mortimer_ultra_kiss_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_mortimer_ultra_kiss_thinker:OnCreated( kv )
    -- references
    self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
    self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
    self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

    if not IsServer() then return end

    -- dont start aura right off
    self.start = false

    -- create aoe finder particle
    self:PlayEffects( kv.travel_time )
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:OnRefresh( kv )
    -- references
    self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
    self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
    self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

    if not IsServer() then return end

    -- start aura
    self.start = true

    -- stop aoe finder particle
    self:StopEffects()
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:OnRemoved()
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_snapfire_mortimer_ultra_kiss_thinker:IsAura()
    return self.start
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:GetModifierAura()
    return "modifier_snapfire_mortimer_ultra_kiss_debuff"
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:GetAuraRadius()
    return self.radius
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:GetAuraDuration()
    return self.linger
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:PlayEffects( time )
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

    -- Create Particle
    self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
    ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end

function modifier_snapfire_mortimer_ultra_kiss_thinker:StopEffects()
    ParticleManager:DestroyParticle( self.effect_cast, true )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )
end