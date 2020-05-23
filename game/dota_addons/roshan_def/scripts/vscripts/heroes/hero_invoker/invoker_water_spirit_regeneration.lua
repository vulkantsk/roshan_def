invoker_water_spirit_regeneration = class({})
LinkLuaModifier('modifier_invoker_water_spirit_regeneration_buff', 'heroes/hero_invoker/invoker_water_spirit_regeneration', LUA_MODIFIER_MOTION_NONE)

function invoker_water_spirit_regeneration:GetIntrinsicModifierName()
    return 'modifier_invoker_water_spirit_regeneration_buff'
end

modifier_invoker_water_spirit_regeneration_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        }
    end,

    GetModifierHealthRegenPercentage = function(self) return self.heal end,
})

function modifier_invoker_water_spirit_regeneration_buff:OnCreated()
    self.heal = self:GetAbility():GetSpecialValueFor('regeneration')
end
function modifier_invoker_water_spirit_regeneration_buff:OnRefresh()
    self.heal = self:GetAbility():GetSpecialValueFor('regeneration')
end  
