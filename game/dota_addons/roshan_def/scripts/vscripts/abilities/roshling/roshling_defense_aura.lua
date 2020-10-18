LinkLuaModifier("modifier_roshdef_roshling_defense_aura", "abilities/roshling/roshling_defense_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_roshdef_roshling_defense_aura_buff", "abilities/roshling/roshling_defense_aura.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshling_defense_aura = class({
    GetIntrinsicModifierName = function()
        return "modifier_roshdef_roshling_defense_aura"
    end
})

modifier_roshdef_roshling_defense_aura = class({
    IsHidden = function()
        return false
    end,
    IsPurgable = function()
        return false
    end,
    IsDebuff = function()
        return false
    end,
    RemoveOnDeath = function()
        return false
    end,
    AllowIllusionDuplicate = function()
        return false
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    IsAuraActiveOnDeath = function()
        return false
    end,
    GetAuraRadius = function(self)
        return self:GetAbility():GetSpecialValueFor("radius")
    end,
    GetAuraSearchFlags = function()
        return DOTA_UNIT_TARGET_FLAG_NONE
    end,
    GetAuraSearchTeam = function()
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function()
        return true
    end,
    GetAuraSearchType = function()
        return DOTA_UNIT_TARGET_ALL
    end,
    GetModifierAura = function()
        return "modifier_roshdef_roshling_defense_aura_buff"
    end
})

modifier_roshdef_roshling_defense_aura_buff = class({
    IsHidden = function()
        return false
    end,
    IsPurgable = function()
        return false
    end,
    IsDebuff = function()
        return false
    end,
    RemoveOnDeath = function()
        return true
    end,
    AllowIllusionDuplicate = function()
        return false
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end,
    DeclareFunctions = function()
        return
        {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
        }
    end,
    GetModifierPhysicalArmorBonus = function(self)
        return self:GetAbility():GetSpecialValueFor("bonus_armor")
    end
})