invoker_exort_fire_enchant = class({})
LinkLuaModifier('modifier_invoker_exort_fire_enchant_buff', 'heroes/hero_invoker/invoker_exort_fire_enchant', LUA_MODIFIER_MOTION_NONE)

function invoker_exort_fire_enchant:OnSpellStart()
    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_invoker_exort_fire_enchant_buff', {
        duration = self:GetSpecialValueFor('duration')
    })


    self:GetCaster():StartGesture(ACT_DOTA_CAST_ALACRITY)
end 

modifier_invoker_exort_fire_enchant_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,

    DeclareFunctions        = function(self)
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end,
})

function modifier_invoker_exort_fire_enchant_buff:OnAttackLanded(data)
    if IsClient() then return end 

    if data.attacker ~= self.parent then  return end

    ApplyDamage({
        victim = data.target,
        attacker = self.parent,
        damage = self.dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability,
    })

end 

function modifier_invoker_exort_fire_enchant_buff:OnCreated()
    if IsClient() then return end 
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local bonus_magic_damage_pct = ability:GetSpecialValueFor('bonus_magic_damage_pct') * caster:GetIntellect() / 100
    print(bonus_magic_damage_pct)
    local base_damage = ability:GetSpecialValueFor('base_damage')
    self.parent = self:GetParent()
    self.ability = ability
    self.dmg = bonus_magic_damage_pct + base_damage
end 

function modifier_invoker_exort_fire_enchant_buff:OnRefresh()
    self:OnCreated()
end 