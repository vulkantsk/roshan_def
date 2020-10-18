LinkLuaModifier("modiifer_roshdef_roshan_slam_slow", "abilities/roshan/roshan_slam.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modiifer_roshdef_roshan_slam_knockback", "abilities/roshan/roshan_slam.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_slam = class({})

function roshdef_roshan_slam:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPosition = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),
            casterPosition,
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false)
    local damageTable = {
        victim = nil,
        damage = self:GetSpecialValueFor("damage"),
        damage_type = self:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        attacker = caster,
        ability = self
    }
    local slowDuration = self:GetSpecialValueFor("slow_duration")
    local knockbackDistance = self:GetSpecialValueFor("knockback_distance")
    local knockbackDuration = self:GetSpecialValueFor("knockback_duration")
    for _, enemy in pairs(enemies) do
        damageTable.victim = enemy
        ApplyDamage(damageTable)
        enemy:AddNewModifier(
                caster,
                self,
                "modiifer_roshdef_roshan_slam_slow",
                {
                    duration = slowDuration
                }
        )
        enemy:AddNewModifier(
                caster,
                self,
                "modiifer_roshdef_roshan_slam_knockback",
                {
                    duration = knockbackDuration,
                    distance = knockbackDistance
                }
        )
    end
    local pidx = ParticleManager:CreateParticle("particles/neutral_fx/roshan_slam.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(pidx)
    EmitSoundOn("Roshan.Slam", caster)
end

modiifer_roshdef_roshan_slam_slow = class({
    IsHidden = function()
        return false
    end,
    IsPurgable = function()
        return true
    end,
    IsDebuff = function()
        return true
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
        return self.msSlow
    end,
    GetModifierAttackSpeedBonus_Constant = function(self)
        return self.asSlow
    end,
})

function modiifer_roshdef_roshan_slam_slow:OnCreated()
    local ability = self:GetAbility()
    self.msSlow = -ability:GetSpecialValueFor("slow_ms")
    self.asSlow = -ability:GetSpecialValueFor("slow_as")
end

modiifer_roshdef_roshan_slam_knockback = class({
    IsHidden = function()
        return true
    end,
    IsPurgable = function()
        return false
    end,
    IsDebuff = function()
        return true
    end,
    RemoveOnDeath = function()
        return true
    end,
    AllowIllusionDuplicate = function()
        return true
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_PROPERTY_OVERRIDE_ANIMATION
        }
    end,
    GetOverrideAnimation = function()
        return ACT_DOTA_FLAIL
    end
})

function modiifer_roshdef_roshan_slam_knockback:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.startPosition = self.parent:GetAbsOrigin()
    self.distance = kv.distance or 0
    self.direction = CalculateDirection(self.startPosition, self:GetCaster():GetAbsOrigin())
    self.distanceTraveled = 0
    self.speed = (self.distance / kv.duration) * FrameTime()
    self:StartMotionController()
end

function modiifer_roshdef_roshan_slam_knockback:DoControlledMotion()
    if not IsServer() then
        return
    end
    if self.distanceTraveled < (self.distance - self.speed) then
        local newPos = GetGroundPosition(self.parent:GetAbsOrigin(), self.parent) + self.direction * self.speed
        self.parent:SetAbsOrigin(newPos)
        self.distanceTraveled = self.distanceTraveled + self.speed
    else
        self:Destroy()
    end
end

function modiifer_roshdef_roshan_slam_knockback:OnDestroy()
    if not IsServer() then
        return
    end
    GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.parent:GetHullRadius(), true)
    self:StopMotionController()
end