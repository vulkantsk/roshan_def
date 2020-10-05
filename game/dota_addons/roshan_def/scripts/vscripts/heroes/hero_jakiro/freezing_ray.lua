LinkLuaModifier("modifier_jakiro_freezing_ray", "heroes/hero_jakiro/freezing_ray", 0)
LinkLuaModifier("modifier_jakiro_freezing_ray_debuff", "heroes/hero_jakiro/freezing_ray", 0)
LinkLuaModifier("modifier_jakiro_freezing_ray_freeze", "heroes/hero_jakiro/freezing_ray", 0)

jakiro_freezing_ray = class({})

function jakiro_freezing_ray:OnUpgrade()
    self:GetCaster():FindAbilityByName("jakiro_freezing_ray_stop"):SetLevel(1)
end

function jakiro_freezing_ray:OnSpellStart()
    if IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_jakiro_freezing_ray", {duration = self:GetSpecialValueFor("beam_duration")})
    caster:SwapAbilities(self:GetName(), "jakiro_freezing_ray_stop", false, true)
end

modifier_jakiro_freezing_ray = class({
    IsPurgable = function() return false end,
    CheckState = function() return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	} end,
	DeclareFunctions = function() return {
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	} end,
	GetModifierIgnoreCastAngle = function() return 1 end
})

function modifier_jakiro_freezing_ray:GetModifierTurnRate_Percentage()
    return -self:GetAbility():GetSpecialValueFor("turn_rate_slow_pct")
end

function modifier_jakiro_freezing_ray:OnCreated()
    if IsServer() then return end
    local caster = self:GetCaster()
    self.pfx = ParticleManager:CreateParticle("particles/jakiro/jakiro_sunray_solar_forge.vpcf", PATTACH_WORLDORIGIN, caster)
    self:AddParticle(self.pfx, false, false, -1, false, false)

    self.disabled_abilities = {
        "jakiro_dual_breath_new",
        "jakiro_fire_ball",
        "jakiro_ice_ball",
        "jakiro_freezing_ray",
        "jakiro_ice_and_fire"
    }
    for _, ability in pairs(self.disabled_abilities) do
        caster:FindAbilityByName(ability):SetActivated(false)
    end

    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))

    EmitSoundOn("Hero_Phoenix.SunRay.Beam", self:GetParent())
    StartSoundEvent("Hero_Phoenix.SunRay.Loop", self:GetParent())
end

function modifier_jakiro_freezing_ray:OnDestroy()
    if IsServer() then return end
    for _, ability in pairs(self.disabled_abilities) do
        self:GetCaster():FindAbilityByName(ability):SetActivated(true)
    end
    self:GetCaster():SwapAbilities("jakiro_freezing_ray_stop", self:GetAbility():GetName(), false, true)
    StopSoundEvent ("Hero_Phoenix.SunRay.Loop", self:GetParent())
    EmitSoundOn ("Hero_Phoenix.SunRay.Stop", self:GetParent())
end

function modifier_jakiro_freezing_ray:OnIntervalThink()
    if IsServer() then return end
    local caster = self:GetCaster()
    ParticleManager:SetParticleControl(self.pfx, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(self.pfx, 1, caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * self:GetAbility():GetSpecialValueFor("beam_range"))
    ParticleManager:SetParticleControl(self.pfx, 9, caster:GetAbsOrigin())
    caster:ModifyHealth(caster:GetHealth() - (caster:GetHealth() / 100 * self:GetAbility():GetSpecialValueFor("hp_spend_pct") * self:GetAbility():GetSpecialValueFor("tick_interval")), self:GetAbility(), false, 0)
	local units_in_path = FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * self:GetSpecialValueFor("beam_range"), nil, self:GetAbility():GetSpecialValueFor("beam_width"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags())
    for _, target in pairs(units_in_path) do
        if target:GetTeam() ~= caster:GetTeam() then
            if not target:HasModifier("modifier_jakiro_freezing_ray_debuff") then
                target:AddNewModifier(caster, self:GetAbility(), "modifier_jakiro_freezing_ray_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
            elseif target:HasModifier("modifier_jakiro_freezing_ray_debuff") then
                target:FindModifierByName("modifier_jakiro_freezing_ray_debuff"):IncrementStackCount()
                target:FindModifierByName("modifier_jakiro_freezing_ray_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("debuff_duration"), true)
            end
            ApplyDamage({
                victim = target,
                attacker = caster,
                ability = self:GetAbility(),
                damage = self:GetAbility():GetSpecialValueFor("damage") * self:GetSpecialValueFor("tick_interval"),
                damage_type = self:GetAbility():GetAbilityDamageType()
            })
        elseif target:GetTeam() == caster:GetTeam() then
            target:Heal(self:GetAbility():GetSpecialValueFor("damage") / 100 * self:GetAbility():GetSpecialValueFor("damage_to_heal_pct") * self:GetSpecialValueFor("tick_interval"), caster)
        end
    end
end

modifier_jakiro_freezing_ray_debuff = class({
    IsPurgable = function() return false end,
    DeclareFunctions = function() return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    } end
})

function modifier_jakiro_freezing_ray_debuff:OnCreated()
    self:SetStackCount(1)
    self.bIsFrozen = false
    self:StartIntervalThink(FrameTime())
end

function modifier_jakiro_freezing_ray_debuff:OnIntervalThink()
    if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stack_for_freeze") and not self.bIsFrozen then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jakiro_freezing_ray_freeze", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
        self.bIsFrozen = true
        self:StartIntervalThink(-1)
    elseif self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stack_for_freeze") then
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("stack_for_freeze"))
    end
end

function modifier_jakiro_freezing_ray_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * -self:GetAbility():GetSpecialValueFor("movespeed_reduction_per_stack")
end

modifier_jakiro_freezing_ray_freeze = class({
    IsHidden = function() return false end,
    IsPurgable = function() return false end,
    IsPurgeException = function() return true end,
    CheckState = function() return {
        [MODIFIER_STATE_STUNNED] = true
    } end
})

function modifier_jakiro_freezing_ray_freeze:OnCreated()
    local pfx = ParticleManager:CreateParticle("", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(pfx, false, false, -1, false, false)
end

jakiro_freezing_ray_stop = class({})
function jakiro_freezing_ray_stop:OnSpellStart()
    self:GetCaster():RemoveModifierByName("modifier_jakiro_freezing_ray")
end