invoker_quas_water_shield = class({})
LinkLuaModifier('modifier_invoker_quas_water_shield_buff', 'heroes/hero_invoker/invoker_quas_water_shield', LUA_MODIFIER_MOTION_NONE)

function invoker_quas_water_shield:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local base_block = self:GetSpecialValueFor("base_block")
    local str_block = self:GetSpecialValueFor("str_block")/100*caster:GetStrength()

    local modifier = target:AddNewModifier(caster, self, 'modifier_invoker_quas_water_shield_buff', {duration = duration})
    modifier:SetStackCount(base_block+str_block)
    
    EmitSoundOn("invoker_water_shield_cast", target)
    caster:StartGesture(ACT_DOTA_CAST_ALACRITY)
end 

modifier_invoker_quas_water_shield_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    GetEffectName           = function(self) return 'particles/econ/events/ti7/teleport_start_ti7_spin_water.vpcf' end,
    GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
    DeclareFunctions        = function(self)
        return {
--            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
        }
    end,
})

function modifier_invoker_quas_water_shield_buff:OnCreated()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    if IsClient() then return end
    EmitSoundOn("invoker_water_shield_loop", self.parent)

end 

function modifier_invoker_quas_water_shield_buff:OnDestroy()
    if IsClient() then return end
    StopSoundOn("invoker_water_shield_loop", self.parent)
end 

function modifier_invoker_quas_water_shield_buff:OnTakeDamage(data)
    local unit = data.unit
    local damage = data.damage
    if self.parent == unit then
        local newStacks = self:GetStackCount() - data.damage
        local heal = data.damage - (newStacks <  0 and -newStacks or 0)
        self.parent:SetHealth(self.parent:GetHealth() + heal )
        if newStacks < 1 then 
            self:Destroy()
            return
        end 
        self:SetStackCount(newStacks)
    end
end

function modifier_invoker_quas_water_shield_buff:GetModifierPhysical_ConstantBlock()
   return self:GetStackCount()
end
