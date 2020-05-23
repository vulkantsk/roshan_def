ability_chaos_meteor_dummy_unit = class({})

LinkLuaModifier("modifier_invoker_exort_chaos_meteor_debuff_aura", "heroes/hero_invoker/ability_chaos_meteor_dummy_unit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_exort_chaos_meteor_debuff", "heroes/hero_invoker/ability_chaos_meteor_dummy_unit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_chaos_meteor_dummy_unit_buff", "heroes/hero_invoker/ability_chaos_meteor_dummy_unit", LUA_MODIFIER_MOTION_NONE)
function ability_chaos_meteor_dummy_unit:GetIntrinsicModifierName()
    return 'modifier_ability_chaos_meteor_dummy_unit_buff'
end 

function ability_chaos_meteor_dummy_unit:OnProjectileThink(vLocation)
    self:GetCaster():SetOrigin(vLocation)
    GridNav:DestroyTreesAroundPoint(vLocation, self.radius, false)
    CreateModifierThinker(self:GetCaster(), self, 'modifier_invoker_exort_chaos_meteor_debuff_aura', {
        duration = self.particleDuration,
        radius = self.radius,
    }, vLocation, self:GetCaster():GetTeam(), false)
end

function ability_chaos_meteor_dummy_unit:OnProjectileHit(hTarget, vLocation)
    if hTarget then 
        ApplyDamage({
            victim = hTarget,
            attacker = self:GetCaster():GetOwner(),
            damage = self.dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability,
        })
    end 
end

modifier_invoker_exort_chaos_meteor_debuff_aura = class({
    IsPurgable = function() return false end,
	IsAura = function() return true end,
	GetModifierAura = function() return "modifier_invoker_exort_chaos_meteor_debuff" end,
	GetAuraSearchTeam = function() return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType = function() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
    GetAuraRadius = function(self) return self.radius end,
    OnCreated   = function(self,data)
        self.radius = data.radius
    end 
})

modifier_invoker_exort_chaos_meteor_debuff = class({
    OnCreated            = function(self) 
        self.casterAbility = self:GetAbility()
        self.damage = self.casterAbility.dps_thinker*self.casterAbility.dps_interval
        self:StartIntervalThink(self.casterAbility.dps_interval)
    end,
    OnIntervalThink         = function(self)
        if IsClient() then return end 
        ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf", PATTACH_POINT, self:GetParent(), {})

        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster():GetOwner(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.casterAbility.ability,
        })
    end 
})

modifier_ability_chaos_meteor_dummy_unit_buff = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent             = function(self) return true end,

    CheckState              = function(self)
        return {
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_UNSLOWABLE] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
            [MODIFIER_STATE_OUT_OF_GAME] = true,
            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        }
    end,
})