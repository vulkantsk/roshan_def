LinkLuaModifier("modifier_roshdef_roshan_protection_of_the_ancient_buff", "abilities/roshan/roshan_protection_of_the_ancient.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_protection_of_the_ancient = class({
    GetIntrinsicModifierName = function()
        return "modifier_roshdef_roshan_protection_of_the_ancient_buff"
    end
})

modifier_roshdef_roshan_protection_of_the_ancient_buff = class({
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
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
        }
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_roshdef_roshan_protection_of_the_ancient_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.caster.IsAncient = function()
        return true
    end
    self:OnRefresh()
end

function modifier_roshdef_roshan_protection_of_the_ancient_buff:OnRefresh()
    if (not IsServer()) then
        return
    end
    self.maxHpDamageCap = self.ability:GetSpecialValueFor("max_hp_pct_damage_cap") / 100
end

function modifier_roshdef_roshan_protection_of_the_ancient_buff:GetModifierIncomingDamage_Percentage(keys)
    if (not IsServer()) then
        return
    end
    if (keys.target ~= self.caster) then
        return
    end
    local damageCap = self.maxHpDamageCap * self.caster:GetMaxHealth()
    if (keys.damage > damageCap) then
        local casterFinalHealth = self.caster:GetHealth() - damageCap
        local pidx = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControlEnt(pidx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(pidx)
        EmitSoundOn("DOTA_Item.ComboBreaker", self.caster)
        if (casterFinalHealth < 1) then
            return 0
        else
            self.caster:SetHealth(casterFinalHealth)
            return -100
        end
    end
end
