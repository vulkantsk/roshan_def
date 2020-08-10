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
snapfire_gunner_on = class({})
LinkLuaModifier( "modifier_snapfire_gunner_on", "heroes/hero_snapfire/gunner_on", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_gunner_on_passive", "heroes/hero_snapfire/gunner_on", LUA_MODIFIER_MOTION_NONE )

function snapfire_gunner_on:GetIntrinsicModifierName()
    return "modifier_snapfire_gunner_on_passive"
end

function snapfire_gunner_on:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()

    -- load data
    local buff_duration = self:GetSpecialValueFor("buff_duration")

    -- addd buff
    caster:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_snapfire_gunner_on", -- modifier name
        { duration = buff_duration } -- kv
    )

    local index = RandomInt(1, 23)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("snapfire_snapfire_ability3_"..index)    
end


--------------------------------------------------------------------------------
modifier_snapfire_gunner_on = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_snapfire_gunner_on:IsHidden()
    return false
end

function modifier_snapfire_gunner_on:IsDebuff()
    return false
end

function modifier_snapfire_gunner_on:IsStunDebuff()
    return false
end

function modifier_snapfire_gunner_on:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_gunner_on:OnCreated( kv )
    -- references
    self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
    self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
    self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
    self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

    self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

    if not IsServer() then return end
    self:SetStackCount( self.attacks )

    self.records = {}

    -- play Effects & Sound
    self:PlayEffects()
    local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
    EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_snapfire_gunner_on:OnRefresh( kv )
    self:OnCreated(kv)
end

function modifier_snapfire_gunner_on:OnRemoved()
end

function modifier_snapfire_gunner_on:OnDestroy()
    if not IsServer() then return end

    -- stop sound
    local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
    StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_snapfire_gunner_on:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

        MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    }

    return funcs
end

function modifier_snapfire_gunner_on:OnAttack( params )
    if params.attacker~=self:GetParent() then return end
    if self:GetStackCount()<=0 then return end

    -- record attack
    self.records[params.record] = true

    -- play sound
    local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Attack"
    EmitSoundOn( sound_cast, self:GetParent() )

    -- decrement stack
    if self:GetStackCount()>0 then
        self:DecrementStackCount()
    end
end

function modifier_snapfire_gunner_on:OnAttackLanded( params )
    -- play sound
    local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Target"
    EmitSoundOn( sound_cast, params.target )
end

function modifier_snapfire_gunner_on:OnAttackRecordDestroy( params )
    if self.records[params.record] then
        self.records[params.record] = nil

        -- if table is empty and no stack left, destroy
        if next(self.records)==nil and self:GetStackCount()<=0 then
            self:Destroy()
        end
    end
end

function modifier_snapfire_gunner_on:GetModifierAttackRangeBonus()
    if self:GetStackCount()<=0 then return end
    return self.range_bonus
end

function modifier_snapfire_gunner_on:GetModifierAttackSpeedBonus_Constant()
    if self:GetStackCount()<=0 then return end
    return self.as_bonus
end

function modifier_snapfire_gunner_on:GetModifierBaseAttackTimeConstant()
    if self:GetStackCount()<=0 then return end
    return self.bat
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_snapfire_gunner_on:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        3,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0), -- unknown
        true -- unknown, true
    )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        4,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0), -- unknown
        true -- unknown, true
    )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        5,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0), -- unknown
        true -- unknown, true
    )

    -- buff particle
    self:AddParticle(
        effect_cast,
        false, -- bDestroyImmediately
        false, -- bStatusEffect
        -1, -- iPriority
        false, -- bHeroEffect
        false -- bOverheadEffect
    )
end

modifier_snapfire_gunner_on_passive = class({
    IsHidden = function(self) return true end,
    DeclareFunctions = function(self) return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }end,
})

function modifier_snapfire_gunner_on_passive:OnCreated()
    local ability = self:GetAbility()
    self.caster = self:GetCaster()
    local attack_interval = ability:GetSpecialValueFor("attack_interval")
    self.attack_radius = ability:GetSpecialValueFor("attack_radius")

    self:StartIntervalThink(attack_interval)
end

function modifier_snapfire_gunner_on_passive:OnRefresh()
    self:OnCreated()
end

function modifier_snapfire_gunner_on_passive:OnIntervalThink()
    local caster = self.caster
    local point = caster:GetAbsOrigin()

    local keys = {flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE} 
    local enemies = caster:FindEnemyUnitsInRadius(point, self.attack_radius, keys)
    local enemy = enemies[RandomInt(1, #enemies)]

    if enemy and caster:IsAlive() then
        caster:PerformAttack(enemy, false, true, true, false, true, false, false)
    end
end

function modifier_snapfire_gunner_on_passive:GetModifierProjectileName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
end
