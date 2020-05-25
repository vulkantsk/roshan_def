invoker_water_spirit_regeneration = class({})
LinkLuaModifier('modifier_invoker_water_spirit_regeneration_buff', 'heroes/hero_invoker/invoker_water_spirit_regeneration', LUA_MODIFIER_MOTION_NONE)

function invoker_water_spirit_regeneration:OnSpellStart()
   local caster =self:GetCaster()
   local duration = self:GetSpecialValueFor("duration")
   
   caster:AddNewModifier(caster, self, "modifier_invoker_water_spirit_regeneration_buff", {duration = duration})
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

function modifier_invoker_water_spirit_regeneration_buff:GetEffectName()
    return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end

function modifier_invoker_water_spirit_regeneration_buff:OnCreated()
    self.heal = self:GetAbility():GetSpecialValueFor('regeneration')
end
function modifier_invoker_water_spirit_regeneration_buff:OnRefresh()
    self.heal = self:GetAbility():GetSpecialValueFor('regeneration')
end  
