invoker_quas_cold_snap = class({})
LinkLuaModifier('modifier_invoker_quas_cold_snap_debuff', 'heroes/hero_invoker/invoker_quas_cold_snap', LUA_MODIFIER_MOTION_NONE)

function invoker_quas_cold_snap:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor('duration')
    caster:StartGesture(ACT_DOTA_CAST_COLD_SNAP)
    caster:EmitSound("Hero_Invoker.ColdSnap.Cast")
    caster:EmitSound("invoker_invo_ability_coldsnap_0" .. RandomInt(1,5))

    target:EmitSound("Hero_Invoker.ColdSnap")
    target:AddNewModifier(caster, self, 'modifier_invoker_quas_cold_snap_debuff', {
        duration = duration
    })
end 

modifier_invoker_quas_cold_snap_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end,
})

function modifier_invoker_quas_cold_snap_debuff:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
end

function modifier_invoker_quas_cold_snap_debuff:OnCreated(table)
    if IsClient() then return end 
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.damageTake = self.damageTake or 0

    self.stun_duration =  self.ability:GetSpecialValueFor('stun_duration')
    self.pct_damage =  self.ability:GetSpecialValueFor('pct_damage')/100
    self.damage_type = self.ability:GetAbilityDamageType()
    self:StartIntervalThink(self.ability:GetSpecialValueFor('interval'))

    self.parent:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self.stun_duration})
    
    local effect = "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf"
    local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:ReleaseParticleIndex(pfx)
end 

function modifier_invoker_quas_cold_snap_debuff:OnIntervalThink()
    if IsClient() then return end 
    ApplyDamage({
        attacker = self.caster,
        victim = self.parent,
        damage = self.damageTake * self.pct_damage,
        damage_type = self.damage_type,
        damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
        ability = self.ability,
    })
    self.parent:EmitSound("Hero_Invoker.ColdSnap")
    self.parent:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = self.stun_duration})
    
    local effect = "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf"
    local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:ReleaseParticleIndex(pfx)
    self.damageTake = 0
end

function modifier_invoker_quas_cold_snap_debuff:OnRefresh(table)
    self:OnCreated()
end 


function modifier_invoker_quas_cold_snap_debuff:OnTakeDamage( data )
    if IsServer() and data.unit == self.parent then
        local flDamage = data.damage
        self.damageTake = self.damageTake + flDamage
    end
end