modifier_roshan_megamode_buff = class({
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
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
            MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
        }
    end,
    GetModifierPhysicalArmorBonus = function(self)
        return self.armorBonus
    end,
    GetModifierMagicalResistanceBonus = function(self)
        return self.spellResBonus
    end,
    GetModifierConstantHealthRegen = function(self)
        return self.hpRegBonus
    end,
    GetModifierBaseAttack_BonusDamage = function(self)
        return self.aaDmgBonus
    end,
    GetModifierMoveSpeedBonus_Constant = function(self)
        return self.msBonus
    end,
    GetModifierStatusResistanceStacking = function(self)
        return self.statusResBonus
    end
})

function modifier_roshan_megamode_buff:OnCreated()
    local parent = self:GetParent()
    self.maxHpBonus = 100000
    self.armorBonus = 50
    self.spellResBonus = 25
    self.hpRegBonus = 1000
    self.aaDmgBonus = 15000
    self.bat = 0.5
    self.msBonus = 400
    self.statusResBonus = 75
    if (parent:GetUnitName() == "npc_dota_roshan2") then
        self.maxHpBonus = 25000
        self.armorBonus = 25
        self.spellResBonus = 25
        self.hpRegBonus = 250
        self.aaDmgBonus = 5000
        self.bat = 0.75
        self.msBonus = 400
        self.statusResBonus = 0
    end
    if (not IsServer()) then
        return
    end
    parent:SetBaseMaxHealth(self.maxHpBonus)
    parent:SetMaxHealth(self.maxHpBonus)
    parent:SetHealth(self.maxHpBonus)
    parent:SetBaseAttackTime(self.bat)
    local radius = parent:GetPaddedCollisionRadius() + 50
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(pidx, 1, Vector(radius, 0, radius))
    ParticleManager:ReleaseParticleIndex(pidx)
end