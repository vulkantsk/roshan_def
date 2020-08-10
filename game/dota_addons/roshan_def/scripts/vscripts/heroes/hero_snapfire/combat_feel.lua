LinkLuaModifier('modifier_snapfire_combat_feel_aura', 'heroes/hero_snapfire/combat_feel', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_snapfire_combat_feel', 'heroes/hero_snapfire/combat_feel', LUA_MODIFIER_MOTION_NONE)

snapfire_combat_feel = class({})

function snapfire_combat_feel:GetCastRange()
    return self:GetSpecialValueFor("aura_radius")
end

function snapfire_combat_feel:GetIntrinsicModifierName()
    return "modifier_snapfire_combat_feel_aura"
end

modifier_snapfire_combat_feel_aura = class({
    IsHidden = function(self) return true end,
    IsAura = function(self) return true end,
    GetAuraRadius = function(self) return self.aura_radius end,
    GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
    GetModifierAura = function(self) return "modifier_snapfire_combat_feel" end,
    GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
})

function modifier_snapfire_combat_feel_aura:OnCreated()
    self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
end

modifier_snapfire_combat_feel = class({
    IsHidden = function(self) return false end,
    DeclareFunctions = function(self) return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }end,
})

function modifier_snapfire_combat_feel:OnCreated()
    self.bonus_dmg = self:GetAbility():GetSpecialValueFor("bonus_dmg")
    self.bonus_spell = self:GetAbility():GetSpecialValueFor("bonus_spell")
end

function modifier_snapfire_combat_feel:OnRefresh()
    self:OnCreated()
end

function modifier_snapfire_combat_feel:GetModifierBaseDamageOutgoing_Percentage()
    return self.bonus_dmg
end

function modifier_snapfire_combat_feel:GetModifierSpellAmplify_Percentage()
    return self.bonus_spell
end
