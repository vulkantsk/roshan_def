LinkLuaModifier('modifier_snapfire_rocket_flare_aura', 'heroes/hero_snapfire/rocket_flare', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_snapfire_rocket_flare', 'heroes/hero_snapfire/rocket_flare', LUA_MODIFIER_MOTION_NONE)

snapfire_rocket_flare = class({})

function snapfire_rocket_flare:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function snapfire_rocket_flare:OnSpellStart()
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()

    local thinker = CreateModifierThinker(caster, self, "modifier_snapfire_rocket_flare_aura", nil, point, caster:GetTeam(), false)
    
    ProjectileManager:CreateTrackingProjectile({
        Target = thinker,
        Source = caster,
        Ability = self,
        EffectName = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare.vpcf",
        bDodgeable = false,
        bProvidesVision = true,
        iMoveSpeed = 1500,
        iVisionRadius = 250,
        iVisionTeamNumber = caster:GetTeamNumber(),
    })  

    local index = RandomInt(1, 18)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("snapfire_snapfire_ability1_"..index)        
end

function snapfire_rocket_flare:OnProjectileHit(hTarget, vLocation)
    if hTarget then
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local radius = self:GetSpecialValueFor("radius")

        hTarget:AddNewModifier(caster, self, "modifier_snapfire_rocket_flare_aura", {duration = duration})
        AddFOWViewer(caster:GetTeam(), hTarget:GetAbsOrigin(), radius, duration, true)
    end
end

modifier_snapfire_rocket_flare_aura = class({
    IsHidden = function(self) return true end,
    IsAura = function(self) return self.start end,
    GetAuraRadius = function(self) return self.radius end,
    GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
    GetModifierAura = function(self) return "modifier_snapfire_rocket_flare" end,
    GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
})

function modifier_snapfire_rocket_flare_aura:OnCreated()
    self.start = false
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_snapfire_rocket_flare_aura:OnRefresh()
    self.start = true
end

modifier_snapfire_rocket_flare = class({
    IsHidden = function(self) return false end,
    DeclareFunctions = function(self) {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }end,
})

function modifier_snapfire_rocket_flare:OnCreated()
    self.armor_decrease = self:GetAbility():GetSpecialValueFor("armor_decrease")
end

function modifier_snapfire_rocket_flare:GetModifierPhysicalArmorBonus()
    return self.armor_decrease*(-1)
end