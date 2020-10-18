LinkLuaModifier("modifier_roshdef_roshan_bash_buff", "abilities/roshan/roshan_bash.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_bash = class({
    GetIntrinsicModifierName = function()
        return "modifier_roshdef_roshan_bash_buff"
    end
})

modifier_roshdef_roshan_bash_buff = class({
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
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_roshdef_roshan_bash_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self:OnRefresh()
end

function modifier_roshdef_roshan_bash_buff:OnRefresh()
    if (not IsServer()) then
        return
    end
    self.chance = self.ability:GetSpecialValueFor("chance")
    self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_roshdef_roshan_bash_buff:OnAttackLanded(keys)
    if (not IsServer()) then
        return
    end
    if (keys.target:IsOther() or keys.target:IsBuilding() or keys.target:GetTeamNumber() == self.casterTeam) then
        return
    end
    if (keys.attacker == self.caster and RollPercentage(self.chance)) then
        keys.target:AddNewModifier(
                self.caster,
                self.ability,
                "modifier_bashed",
                {
                    duration = self.duration
                }
        )
        EmitSoundOn("Roshan.Bash", keys.target)
    end
end