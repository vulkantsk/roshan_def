invoker_exort_fire_enchant = class({})
LinkLuaModifier('modifier_invoker_exort_fire_enchant_buff', 'heroes/hero_invoker/invoker_exort_fire_enchant', LUA_MODIFIER_MOTION_NONE)

function invoker_exort_fire_enchant:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local base_dmg = self:GetSpecialValueFor("base_dmg")
    local int_dmg = self:GetSpecialValueFor("int_dmg")/100*caster:GetIntellect()

    local modifier = target:AddNewModifier(caster, self, 'modifier_invoker_exort_fire_enchant_buff', {duration = duration})
    modifier:SetStackCount(base_dmg+int_dmg)

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
            MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        }
    end,
})
function modifier_invoker_exort_fire_enchant_buff:GetModifierProcAttack_BonusDamage_Magical()
    return self:GetStackCount()
end

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
function modifier_invoker_exort_fire_enchant_buff:GetEffectName()
    return 0--"particles/units/heroes/hero_warlock/golem_ambient.vpcf"
end

function modifier_invoker_exort_fire_enchant_buff:OnCreated()
    if IsClient() then return end 
    local parent = self:GetParent()
    local point = parent:GetAbsOrigin()

    local particle = "particles/econ/items/warlock/warlock_golem_dark_curator/golem_ambient_dark_curator.vpcf"
    local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, parent)
    ParticleManager:SetParticleControlEnt(pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_head", point, true)
    ParticleManager:SetParticleControlEnt(pfx, 10, parent, PATTACH_POINT_FOLLOW, "attach_attack1", point, true)
    ParticleManager:SetParticleControlEnt(pfx, 11, parent, PATTACH_POINT_FOLLOW, "attach_attack2", point, true)
    self:AddParticle(pfx, true, false, 3, true, false)
    
end 

function modifier_invoker_exort_fire_enchant_buff:OnRefresh()
--    self:OnCreated()
end 