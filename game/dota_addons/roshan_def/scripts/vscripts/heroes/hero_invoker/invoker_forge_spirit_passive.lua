invoker_forge_spirit_passive = class({})
LinkLuaModifier('modifier_invoker_forge_spirit_passive_buff', 'heroes/hero_invoker/invoker_forge_spirit_passive', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_forge_spirit_passive_debuff', 'heroes/hero_invoker/invoker_forge_spirit_passive', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_forge_spirit_passive_debuff_stacks', 'heroes/hero_invoker/invoker_forge_spirit_passive', LUA_MODIFIER_MOTION_NONE)
function invoker_forge_spirit_passive:GetIntrinsicModifierName()
    return 'modifier_invoker_forge_spirit_passive_buff'
end 

modifier_invoker_forge_spirit_passive_buff = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent             = function(self) return true end,

    DeclareFunctions        = function(self) 
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end,
})

function modifier_invoker_forge_spirit_passive_buff:OnCreated()
    if IsClient() then return end 

    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.duration = self.ability:GetSpecialValueFor('duration')
    print('check')

end 

function modifier_invoker_forge_spirit_passive_buff:OnRefresh()
    if IsClient() then return end 

    self:OnCreated()

end 


function modifier_invoker_forge_spirit_passive_buff:OnAttackLanded(data)
    if self.parent ~= data.attacker then return end

    data.target:AddStackModifier({
        ability = self.ability,
        modifier = 'modifier_invoker_forge_spirit_passive_debuff_stacks',
        duration = self.duration,
        updateStack = true,
        caster = self.parent,
    })

    data.target:AddNewModifier(self.parent, self.ability, 'modifier_invoker_forge_spirit_passive_debuff', {
        duration = self.duration,
    })
end 

modifier_invoker_forge_spirit_passive_debuff_stacks = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent             = function(self) return true end, 
})


modifier_invoker_forge_spirit_passive_debuff = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent             = function(self) return true end, 
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_invoker_forge_spirit_passive_debuff:OnCreated()
    if IsClient() then return end 

    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.dmg_type = self.ability:GetAbilityDamageType()
    self.dmg_per_tick = self.ability:GetSpecialValueFor('dmg_per_tick')

    self:StartIntervalThink(self.ability:GetSpecialValueFor('tick'))

end 

function modifier_invoker_forge_spirit_passive_debuff:OnIntervalThink()
    if IsClient() then return end 

    ApplyDamage({
        victim = self.parent,
        attacker = self.caster,
        damage = self.dmg_per_tick,
        damage_type = self.dmg_type,
        ability = self.ability,
    })
end 


function modifier_invoker_forge_spirit_passive_debuff:OnDestroy()
    if IsClient() then return end 

    self.parent:AddStackModifier({
        ability = self.ability,
        modifier = 'modifier_invoker_forge_spirit_passive_debuff_stacks',
        count = -1,
        caster = self.caster,
    })

end 

function modifier_invoker_forge_spirit_passive_debuff:OnRefresh()
    if IsClient() then return end 

    self:OnCreated()

end 