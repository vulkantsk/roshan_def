LinkLuaModifier("modifier_faceless_void_flash_speed", "heroes/hero_faceless_void/flash_speed", LUA_MODIFIER_MOTION_NONE)


faceless_void_flash_speed = class({})

function faceless_void_flash_speed:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    
    caster:EmitSound("Hero_FacelessVoid.TimeDilation.Cast")
    caster:AddNewModifier(caster, self, "modifier_faceless_void_flash_speed", {duration = duration})
 end 

modifier_faceless_void_flash_speed = class ({
    IsHidden = function(self) return false end, 
    RemoveOnDeath = function(self) return true end, 
    IsPurgable = function(self) return false end, 
    DeclareFunctions        = function(self) return 
        {   
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
            MODIFIER_PROPERTY_MODEL_SCALE,
            MODIFIER_PROPERTY_EVASION_CONSTANT,
        } end,
})

function modifier_faceless_void_flash_speed:OnCreated()
    local ability = self:GetAbility()

    self.model_scale = ability:GetSpecialValueFor("model_scale")
    self.bonus_ms = ability:GetSpecialValueFor("bonus_ms")
    self.bonus_bat = ability:GetSpecialValueFor("bonus_bat")
    self.bonus_evasion = ability:GetSpecialValueFor("bonus_evasion")

end

function modifier_faceless_void_flash_speed:GetModifierModelScale()
    return self.model_scale*(-1)
end

function modifier_faceless_void_flash_speed:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms
end

function modifier_faceless_void_flash_speed:GetModifierBaseAttackTimeConstant()
    return self.bonus_bat
end

function modifier_faceless_void_flash_speed:GetModifierEvasion_Constant()
    return self.bonus_evasion
end


