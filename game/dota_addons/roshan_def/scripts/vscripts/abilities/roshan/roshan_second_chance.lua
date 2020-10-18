LinkLuaModifier("modifier_roshdef_roshan_second_chance_buff", "abilities/roshan/roshan_second_chance.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_second_chance = class({
    GetIntrinsicModifierName = function()
        return "modifier_roshdef_roshan_second_chance_buff"
    end
})

modifier_roshdef_roshan_second_chance_buff = class({
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
            MODIFIER_PROPERTY_REINCARNATION,
            MODIFIER_EVENT_ON_RESPAWN
        }
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_roshdef_roshan_second_chance_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.currentProcs = 0
    self:OnRefresh()
end

function modifier_roshdef_roshan_second_chance_buff:OnRefresh()
    if (not IsServer()) then
        return
    end
    self.maxProcs = self.ability:GetSpecialValueFor("max_procs")
    self.respawnDelay = self.ability:GetSpecialValueFor("respawn_delay")
    self.respawnHpPercent = self.ability:GetSpecialValueFor("respawn_hp_pct") / 100
end

function modifier_roshdef_roshan_second_chance_buff:ReincarnateTime()
    if (not IsServer()) then
        return
    end
    if(self.currentProcs < self.maxProcs) then
        self.reincarnated = true
        self.currentProcs = self.currentProcs + 1
        local pidx = ParticleManager:CreateParticle("particles/items_fx/aegis_timer.vpcf", PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(pidx, 1, Vector(self.respawnDelay, 0, 0))
        ParticleManager:ReleaseParticleIndex(pidx)
        return self.respawnDelay
    end
    self.reincarnated = nil
    return nil
end

function modifier_roshdef_roshan_second_chance_buff:OnRespawn(keys)
    if (not IsServer()) then
        return
    end
    if(keys.unit == self.caster and self.reincarnated) then
        local pidx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:ReleaseParticleIndex(pidx)
        self.caster:SetHealth(self.caster:GetMaxHealth() * self.respawnHpPercent)
    end
end