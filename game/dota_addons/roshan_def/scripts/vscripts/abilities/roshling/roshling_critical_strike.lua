LinkLuaModifier("modifier_roshdef_roshling_critical_strike_buff", "abilities/roshling/roshling_critical_strike.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshling_critical_strike = class({
    GetIntrinsicModifierName = function()
        return "modifier_roshdef_roshling_critical_strike_buff"
    end
})

modifier_roshdef_roshling_critical_strike_buff = class({
    IsHidden = function()
        return true
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
    DeclareFunctions = function()
        return
        {
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
        }
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_roshdef_roshling_critical_strike_buff:OnCreated()
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self:OnRefresh()
end

function modifier_roshdef_roshling_critical_strike_buff:OnRefresh()
    self.critMultiplier = self.ability:GetSpecialValueFor("crit_multiplier")
    self.critChance = self.ability:GetSpecialValueFor("crit_chance")
end

function modifier_roshdef_roshling_critical_strike_buff:GetModifierPreAttack_CriticalStrike(keys)
    if (keys.target and not keys.target:IsOther() and not keys.target:IsBuilding() and keys.target:GetTeamNumber() ~= self.casterTeam and keys.attacker == self.caster and RollPercentage(self.critChance)) then
        return self.critMultiplier
    end
end