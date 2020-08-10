LinkLuaModifier( "modifier_snapfire_firesnap_cookies", "heroes/hero_snapfire/firesnap_cookies", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_firesnap_cookies_channel", "heroes/hero_snapfire/firesnap_cookies", LUA_MODIFIER_MOTION_NONE )

snapfire_firesnap_cookies = class({})
--------------------------------------------------------------------------------
-- Custom KV
function snapfire_firesnap_cookies:GetCastPoint()
    if IsServer() and self:GetCursorTarget()==self:GetCaster() then
        return self:GetSpecialValueFor( "self_cast_delay" )
    end
    return 0.2
end

function snapfire_firesnap_cookies:GetChannelTime()
    local cookies_count = self:GetSpecialValueFor("cookies_count")
    local cookie_interval = self:GetSpecialValueFor("cookie_interval")
    return cookie_interval*(cookies_count-1)+0.1
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function snapfire_firesnap_cookies:OnChannelFinish(bInterrupted)
    self.target:RemoveModifierByName("modifier_snapfire_firesnap_cookies_channel")
 end

function snapfire_firesnap_cookies:OnAbilityPhaseStart()
    if self:GetCursorTarget()==self:GetCaster() then
        self:PlayEffects1()
    end

    return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function snapfire_firesnap_cookies:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    self.init = true
    self.target = self:GetCursorTarget()

    self.target:AddNewModifier(caster, self, "modifier_snapfire_firesnap_cookies_channel", nil)

    local index = RandomInt(1, 44)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("snapfire_snapfire_ability2_"..index)   

end
--------------------------------------------------------------------------------
-- Projectile
function snapfire_firesnap_cookies:OnProjectileHit( target, location )
    if not target or not target:IsAlive() then return end

    local caster = self:GetCaster()
    local buff_duration = self:GetSpecialValueFor("buff_duration")
    local base_heal = self:GetSpecialValueFor("base_heal")
    local heal_pct = self:GetSpecialValueFor("heal_pct")/100*target:GetMaxHealth()
    local heal_amount = base_heal + heal_pct

    if self.init then
        self.init = false
        local modifier = target:AddNewModifier(caster, self, "modifier_snapfire_firesnap_cookies", {duration = buff_duration})
        modifier:SetStackCount(1)
        target:Heal(heal_amount, self)
    else
        local modifier = target:AddNewModifier(caster, self, "modifier_snapfire_firesnap_cookies", {duration = buff_duration})
        modifier:IncrementStackCount()
        target:Heal(heal_amount, self)
    end
end

--------------------------------------------------------------------------------
function snapfire_firesnap_cookies:PlayEffects1()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function snapfire_firesnap_cookies:PlayEffects2( target )
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf"
    local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
    local sound_target = "Hero_Snapfire.FeedCookie.Consume"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target )

    -- Create Sound
    EmitSoundOn( sound_target, target )

    return effect_cast
end

function snapfire_firesnap_cookies:PlayEffects3( target, radius )
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
    local sound_location = "Hero_Snapfire.FeedCookie.Impact"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
    ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOn( sound_location, target )
end

modifier_snapfire_firesnap_cookies_channel = class({
    IsHidden = function(self) return true end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return true end,
})

function modifier_snapfire_firesnap_cookies_channel:OnCreated()
    local ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.range_maximum = ability:GetCastRange(Vector(0,0,0), nil ) + ability:GetSpecialValueFor("range_buffer")
    self.cookie_interval = ability:GetSpecialValueFor("cookie_interval")
    self.projectile_speed = ability:GetSpecialValueFor( "projectile_speed" )

    self.info = {
        Target = self.parent,
        Source = self.caster,
        Ability = ability, 
        
        EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf",
        iMoveSpeed = self.projectile_speed,
        bDodgeable = false,                           -- Optional
    }

    self:StartIntervalThink(self.cookie_interval)
    self:OnIntervalThink()
end

function modifier_snapfire_firesnap_cookies_channel:OnIntervalThink()
    local range = (self.caster:GetAbsOrigin()-self.parent:GetAbsOrigin()):Length2D()

    if range > self.range_maximum then
        self:Destroy()
    end

    ProjectileManager:CreateTrackingProjectile(self.info)

    self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 2)
    self.caster:EmitSound( "Hero_Snapfire.FeedCookie.Cast" )
end

function modifier_snapfire_firesnap_cookies_channel:OnDestroy()
    self:GetAbility():EndChannel(true)
end

modifier_snapfire_firesnap_cookies = class({
    IsHidden = function(self) return false end,
    DeclareFunctions = function(self) return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }end,
})

function modifier_snapfire_firesnap_cookies:OnCreated()
    local ability = self:GetAbility()
    self.bonus_dmg = ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_ms = ability:GetSpecialValueFor("bonus_ms")
end

function modifier_snapfire_firesnap_cookies:GetModifierBaseDamageOutgoing_Percentage()
    return self.bonus_dmg*self:GetStackCount()
end

function modifier_snapfire_firesnap_cookies:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms*self:GetStackCount()
end
