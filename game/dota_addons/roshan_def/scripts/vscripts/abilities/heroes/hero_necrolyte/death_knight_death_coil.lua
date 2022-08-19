necrolyte_death_knight_death_coil = class({})

function necrolyte_death_knight_death_coil:CastFilterResultTarget(hTarget)
    if hTarget == self:GetCaster() then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function necrolyte_death_knight_death_coil:GetCustomCastErrorTarget()
    return 'dota_hud_error_cant_cast_on_self'
end

function necrolyte_death_knight_death_coil:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    caster:EmitSound('Hero_Abaddon.DeathCoil.Cast')
    
    ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = caster,
        Ability = self,	
        EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf",
        iMoveSpeed = self:GetSpecialValueFor('missile_speed'),
        vSourceLoc= caster:GetAbsOrigin(),
        bDodgeable = false,
    })
end

function necrolyte_death_knight_death_coil:OnProjectileHit(hTarget, vLocation)
    if not hTarget then return end

    hTarget:EmitSound('Hero_Abaddon.DeathCoil.Target')

    if hTarget:GetTeam() ~= self:GetCaster():GetTeam() then 
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
        ApplyDamage({
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = self:GetSpecialValueFor('target_damage'),
            damage_type = self:GetAbilityDamageType(),
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self,
        })
        return true
    end

    hTarget:Heal(self:GetSpecialValueFor('heal_amount'), self:GetCaster())
end