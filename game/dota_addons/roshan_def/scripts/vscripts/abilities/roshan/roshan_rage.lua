LinkLuaModifier("modifier_roshdef_roshan_rage_buff", "abilities/roshan/roshan_rage.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_rage = class({})

function roshdef_roshan_rage:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:AddNewModifier(
            caster,
            self,
            "modifier_roshdef_roshan_rage_buff",
            {
                duration = self:GetSpecialValueFor("duration")
            }
    )
    caster:Purge(false, true, false, false, false)
    caster:EmitSound("Hero_LifeStealer.Rage")
end

modifier_roshdef_roshan_rage_buff = class({
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
        return true
    end,
    DeclareFunctions = function()
        return
        {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
        }
    end,
    GetModifierMoveSpeedBonus_Constant = function(self)
        return self.msBonus
    end,
    GetModifierAttackSpeedBonus_Constant = function(self)
        return self.asBonus
    end,
    CheckState = function()
        return
        {
            [MODIFIER_STATE_MAGIC_IMMUNE] = true
        }
    end
})

function modifier_roshdef_roshan_rage_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_roshdef_roshan_rage_buff:OnRefresh()
    self:OnCreated()
end

function modifier_roshdef_roshan_rage_buff:OnCreated()
    local ability = self:GetAbility()
    self.msBonus = ability:GetSpecialValueFor("bonus_ms")
    self.asBonus = ability:GetSpecialValueFor("bonus_as")
    if (not IsServer()) then
        return
    end
    local caster = self:GetParent()
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(pidx, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    self:AddParticle(pidx, false, false, -1, true, false)
end
