invoker_quas_water_shield = class({})
LinkLuaModifier('modifier_invoker_quas_water_shield_buff', 'heroes/hero_invoker/invoker_quas_water_shield', LUA_MODIFIER_MOTION_NONE)

function invoker_quas_water_shield:OnSpellStart()
    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_invoker_quas_water_shield_buff', {
        duration = self:GetSpecialValueFor('duration'),
    }):SetStackCount(self:GetSpecialValueFor('absorb_damage') + (self:GetCaster():GetStrength() * self:GetSpecialValueFor('absorb_damage_mult'))/100)

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ALACRITY)
end 

modifier_invoker_quas_water_shield_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    GetEffectName           = function(self) return 'particles/econ/events/ti7/mjollnir_shield_ti7.vpcf' end,
    GetEffectAttachType     = function(self) return PATTACH_CENTER_FOLLOW end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end,
})

function modifier_invoker_quas_water_shield_buff:OnCreated()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    if IsClient() then return end
    EmitSoundOn("DOTA_Item.Mjollnir.Activate", self.parent)

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