LinkLuaModifier("modifier_jakiro_freezing_ray_beam_particle", "heroes/hero_jakiro/freezing_ray", 0)
LinkLuaModifier("modifier_jakiro_freezing_ray", "heroes/hero_jakiro/freezing_ray", 0)
LinkLuaModifier("modifier_jakiro_freezing_ray_debuff", "heroes/hero_jakiro/freezing_ray", 0)

jakiro_freezing_ray = class({})

function jakiro_freezing_ray:OnUpgrade()
    self:GetCaster():FindAbilityByName("jakiro_freezing_ray_stop"):SetLevel(1)
end

function jakiro_freezing_ray:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_jakiro_freezing_ray", {duration = self:GetSpecialValueFor("beam_duration")})
    caster:AddNewModifier(caster, self, "modifier_jakiro_freezing_ray_beam_particle", {duration = self:GetSpecialValueFor("beam_duration")})
    EmitSoundOn("Hero_Phoenix.SunRay.Cast", caster)
end

modifier_jakiro_freezing_ray = class({
    IsPurgable = function() return false end,
    RemoveOnDeath = function() return true end,
    DeclareFunctions = function() return {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
    } end,
    GetModifierIgnoreCastAngle = function() return 1 end,
    GetModifierTurnRate_Percentage = function() return -9999 end
})

function modifier_jakiro_freezing_ray:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = self:GetCaster():HasScepter()
    }
end

function modifier_jakiro_freezing_ray:OnCreated()
    local caster = self:GetCaster()
    self.disabled_abilities = {
        "jakiro_dual_breath_new",
        --"jakiro_fire_ball",
        --"jakiro_ice_ball",
        "jakiro_ice_and_fire"
    }
    for _, ability in pairs(self.disabled_abilities) do
        if ability ~= nil then
            caster:FindAbilityByName(ability):SetActivated(false)
        end
    end

    caster:SwapAbilities("jakiro_freezing_ray", "jakiro_freezing_ray_stop", false, true)

    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))

    StartSoundEvent ("Hero_Phoenix.SunRay.Loop", caster)
end

function modifier_jakiro_freezing_ray:OnIntervalThink()
    local caster = self:GetCaster()
    local vStartPos = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1"))
    local vEndPos = caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * self:GetAbility():GetSpecialValueFor("beam_range")
    local units_in_line = FindUnitsInLine(caster:GetTeamNumber(), vStartPos, vEndPos, nil, self:GetAbility():GetSpecialValueFor("beam_width"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags())

    caster:ModifyHealth(caster:GetHealth() - (caster:GetHealth() * 0.01 * self:GetAbility():GetSpecialValueFor("hp_spend_pct")) * self:GetAbility():GetSpecialValueFor("tick_interval"), self:GetAbility(), true, DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS)

    for _, target in pairs(units_in_line) do
        if target:GetTeam() == caster:GetTeam() then
            if target ~= caster then
                local heal = self:GetAbility():GetSpecialValueFor("damage") * self:GetSpecialValueFor("damage_to_heal_pct") * 0.01 * self:GetAbility():GetSpecialValueFor("tick_interval")
                target:Heal(heal, caster)
                SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(), OVERHEAD_ALERT_HEAL, target, heal, nil)
            end
        else
            if not target:HasModifier("modifier_jakiro_freezing_ray_debuff") then
                target:AddNewModifier(caster, self:GetAbility(), "modifier_jakiro_freezing_ray_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
            else
                target:FindModifierByName("modifier_jakiro_freezing_ray_debuff"):IncrementStackCount()
                target:FindModifierByName("modifier_jakiro_freezing_ray_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("debuff_duration"), true)
            end
            ApplyDamage({
                victim = target,
                attacker = caster,
                ability = self:GetAbility(),
                damage = self:GetAbility():GetSpecialValueFor("damage") * self:GetAbility():GetSpecialValueFor("tick_interval"),
                damage_type = self:GetAbility():GetAbilityDamageType()
            })
        end
    end
end

function modifier_jakiro_freezing_ray:OnDestroy()
    local caster = self:GetCaster()
    for _, ability in pairs(self.disabled_abilities) do
        if ability ~= nil then
            caster:FindAbilityByName(ability):SetActivated(true)
        end
    end

    caster:SwapAbilities("jakiro_freezing_ray_stop", "jakiro_freezing_ray", false, true)

    StopSoundEvent ("Hero_Phoenix.SunRay.Loop", caster)
    EmitSoundOn ("Hero_Phoenix.SunRay.Stop", caster)
end

modifier_jakiro_freezing_ray_beam_particle = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end
})

function modifier_jakiro_freezing_ray_beam_particle:OnCreated()
    local caster = self:GetCaster()
    self.pfx = ParticleManager:CreateParticle("particles/jakiro/jakiro_sunray_solar_forge.vpcf", PATTACH_WORLDORIGIN, caster)
    self:AddParticle(self.pfx, false, false, -1, false, false)

    self:StartIntervalThink(FrameTime())
end

function modifier_jakiro_freezing_ray_beam_particle:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    ParticleManager:SetParticleControl(self.pfx, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(self.pfx, 1, caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * self:GetAbility():GetSpecialValueFor("beam_range"))
    ParticleManager:SetParticleControl(self.pfx, 9, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))

    if caster:IsStunned() or caster:IsHexed() or caster:IsNightmared() or caster:IsOutOfGame() or caster:IsFrozen() then
        caster:RemoveModifierByName("modifier_jakiro_freezing_ray")
    end

    if not caster:HasModifier("modifier_jakiro_freezing_ray") then
        caster:RemoveModifierByName(self:GetName())
    end
end


modifier_jakiro_freezing_ray_debuff = class({
    IsHidden = function() return false end,
    IsPurgable = function() return false end,
    IsPurgeException = function() return true end,
    DeclareFunctions = function() return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    } end
})

function modifier_jakiro_freezing_ray_debuff:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stack_for_freeze"),
        [MODIFIER_STATE_FROZEN] = self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stack_for_freeze")
    }
end

function modifier_jakiro_freezing_ray_debuff:OnCreated()
    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
    self.bIsFrozen = false
end

function modifier_jakiro_freezing_ray_debuff:OnIntervalThink()
    if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stack_for_freeze") then
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("stack_for_freeze"))
        if not self.bIsFrozen then
            self:Freeze()
            self.bIsFrozen = true
        end
    end
end

function modifier_jakiro_freezing_ray_debuff:OnDestroy()
    self.bIsFrozen = false
end

function modifier_jakiro_freezing_ray_debuff:GetModifierIncomingDamage_Percentage()
    return self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stack_for_freeze") and self:GetAbility():GetSpecialValueFor("frozen_damage_amp")
end

function modifier_jakiro_freezing_ray_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * -self:GetAbility():GetSpecialValueFor("movespeed_reduction_per_stack_pct")
end

function modifier_jakiro_freezing_ray_debuff:Freeze()
    local pfx = ParticleManager:CreateParticle("particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(pfx, false, false, -1, false, false)
end

jakiro_freezing_ray_stop = class({})

function jakiro_freezing_ray_stop:OnSpellStart()
    if self:GetCaster():HasModifier("modifier_jakiro_freezing_ray") then
        self:GetCaster():RemoveModifierByName("modifier_jakiro_freezing_ray")
    else
        self:GetCaster():SwapAbilities(self:GetName(), "jakiro_freezing_ray", false, true)
    end
end