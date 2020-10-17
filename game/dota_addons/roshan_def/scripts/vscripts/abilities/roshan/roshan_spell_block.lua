LinkLuaModifier("modifier_roshdef_roshan_spell_block_buff", "abilities/roshan/roshan_spell_block.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_spell_block = class({
    GetIntrinsicModifierName = function()
        return "modifier_roshdef_roshan_spell_block_buff"
    end
})

modifier_roshdef_roshan_spell_block_buff = class({
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
        return true
    end,
    AllowIllusionDuplicate = function()
        return false
    end,
    DeclareFunctions = function()
        return
        {
            MODIFIER_PROPERTY_ABSORB_SPELL
        }
    end
})

function modifier_roshdef_roshan_spell_block_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.casterTeam = self:GetParent():GetTeamNumber()
end

function modifier_roshdef_roshan_spell_block_buff:GetAbsorbSpell(keys)
    if (not IsServer()) then
        return
    end
    if (self.casterTeam == keys.ability:GetCaster():GetTeamNumber()) then
        return 0
    end
    if (self.ability:IsCooldownReady()) then
        self.ability:UseResources(true, true, true)
        return 1
    end
    return 0
end