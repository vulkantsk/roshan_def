LinkLuaModifier("modifier_hoodwink_armor_destroy", "heroes/hero_hoodwink/armor_destroy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hoodwink_armor_destroy_debuff", "heroes/hero_hoodwink/armor_destroy", LUA_MODIFIER_MOTION_NONE)


hoodwink_armor_destroy = class({})

function hoodwink_armor_destroy:GetIntrinsicModifierName()
    return "modifier_hoodwink_armor_destroy"
end

modifier_hoodwink_armor_destroy = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_EVENT_ON_ATTACK_LANDED,

        } end,
})

function modifier_hoodwink_armor_destroy:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local ability = self:GetAbility()
            local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
            local target = params.target
            if target:IsBuilding() or target:IsMagicImmune() then
                return
            end

--            EmitSoundOn("Hero_TemplarAssassin.Meld.Attack", target)
            local modifier = target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_hoodwink_armor_destroy_debuff", {Duration = debuff_duration})
            modifier:IncrementStackCount()

       end
    end
end

modifier_hoodwink_armor_destroy_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        } end,
})

function modifier_hoodwink_armor_destroy_debuff:GetModifierPhysicalArmorBonus()
    return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("armor_decrease")*(-1)
end

function modifier_hoodwink_armor_destroy_debuff:GetEffectName()
    return "particles/econ/items/templar_assassin/templar_assassin_focal/templar_meld_focal_overhead.vpcf"
end

function modifier_hoodwink_armor_destroy_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end