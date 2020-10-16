LinkLuaModifier("modifier_roshdef_roshan_fire_breath_dot", "abilities/roshan/roshan_fire_breath.lua", LUA_MODIFIER_MOTION_NONE)

roshdef_roshan_fire_breath = class({})

function roshdef_roshan_fire_breath:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.casterPosition = self.caster:GetAbsOrigin()
    self.casterTeam = self.caster:GetTeamNumber()
    self.damageTable = {
        victim = nil,
        damage = self:GetSpecialValueFor("damage"),
        damage_type = self:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        attacker = self.caster,
        ability = self
    }
    self.projectileSpeed = self:GetSpecialValueFor("arc_projectile_speed")
    self.projectileDistance = self:GetSpecialValueFor("arc_projectile_distance")
    self.projectileStartRadius = self:GetSpecialValueFor("arc_projectile_start_radius")
    self.projectileEndRadius = self:GetSpecialValueFor("arc_projectile_end_radius")
    local startAngle = self:GetSpecialValueFor("arc_start_angle")
    self.currentAngle = ToRadians(startAngle)
    local angleDelta = self:GetSpecialValueFor("arc_angle_delta")
    self.angleDelta = -ToRadians(angleDelta)
    self.direction = CalculateDirection(self.casterPosition + self.caster:GetForwardVector() * 5, self.casterPosition)
    self.interval = self:GetChannelTime() / ((math.abs(startAngle) + math.abs(self:GetSpecialValueFor("arc_end_angle"))) / math.abs(angleDelta))
    self.timer = 0
    self.damagedEnemies = {}
end

function roshdef_roshan_fire_breath:OnChannelThink(dt)
    if (not IsServer()) then
        return
    end
    self.timer = self.timer + dt
    if (self.timer >= self.interval) then
        self.timer = 0
        local newDirection = RotateVector2D(self.direction, self.currentAngle)
        local projectile = {
            Ability = self,
            EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
            vSpawnOrigin = self.casterPosition,
            fDistance = self.projectileDistance,
            fStartRadius = self.projectileStartRadius,
            fEndRadius = self.projectileEndRadius,
            Source = self.caster,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit = true,
            vVelocity = newDirection * self.projectileSpeed,
            bProvidesVision = true,
            iVisionRadius = 125,
            iVisionTeamNumber = self.casterTeam
        }
        ProjectileManager:CreateLinearProjectile(projectile)
        self.currentAngle = self.currentAngle - self.angleDelta
        EmitSoundOn("Hero_Jakiro.DualBreath.Cast", self.caster)
    end
end

function roshdef_roshan_fire_breath:OnProjectileHitHandle(target)
    if (not IsServer()) then
        return
    end
    if (target and not self.damagedEnemies[target]) then
        self.damageTable.victim = target
        ApplyDamage(self.damageTable)
        target:AddNewModifier(
                self.caster,
                self,
                "modifier_roshdef_roshan_fire_breath_dot",
                {
                    duration = self:GetSpecialValueFor("dot_duration")
                }
        )
        self.damagedEnemies[target] = true
    end
end

modifier_roshdef_roshan_fire_breath_dot = class({
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
    GetEffectName = function()
        return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
    end
})

function modifier_roshdef_roshan_fire_breath_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    self.damageTable = {
        victim = self.target,
        damage = self.ability:GetSpecialValueFor("dot_damage"),
        damage_type = self.ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        attacker = self:GetCaster(),
        ability = self.ability
    }
    self:StartIntervalThink(self.ability:GetSpecialValueFor("dot_tick"))
end

function modifier_roshdef_roshan_fire_breath_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    ApplyDamage(self.damageTable)
end