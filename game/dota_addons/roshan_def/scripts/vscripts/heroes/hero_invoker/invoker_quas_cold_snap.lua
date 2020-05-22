invoker_quas_cold_snap = class({})
LinkLuaModifier('modifier_invoker_quas_cold_snap_debuff', 'heroes/hero_invoker/invoker_quas_cold_snap', LUA_MODIFIER_MOTION_NONE)

function invoker_quas_cold_snap:OnSpellStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_COLD_SNAP)

    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_invoker_quas_cold_snap_debuff', {
        duration = self:GetSpecialValueFor('duration')
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

function modifier_invoker_quas_cold_snap_debuff:OnCreated(table)
    if IsClient() then return end 
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.damageTake = self.damageTake or 0

    self.pct_damage =  self.ability:GetSpecialValueFor('pct_damage') * 0.01
    self.damage_type = self.ability:GetAbilityDamageType()
    self:StartIntervalThink(self.ability:GetSpecialValueFor('interval'))

end 

function modifier_invoker_quas_cold_snap_debuff:OnIntervalThink()
    if IsClient() then return end 
    ApplyDamage({
        attacker = self.caster,
        victim = self.parent,
        damage = self.damageTake * self.pct_damage,
        damage_type = self.damage_type,
        ability = self.ability,
    })
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