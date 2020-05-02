LinkLuaModifier("modifier_ability_thief_3_delay", 'abilities/thief/ability_thief_3.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thief_3_debuff", 'abilities/thief/ability_thief_3.lua', LUA_MODIFIER_MOTION_NONE)

ability_thief_3 = class({})
function ability_thief_3:OnSpellStart()
    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_ability_thief_3_delay', {
        duration = self:GetSpecialValueFor('delay')
    })
end

modifier_ability_thief_3_delay = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,
})
 
function modifier_ability_thief_3_delay:OnDestroy()
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), 'modifier_ability_thief_3_debuff', {
        duration = self:GetAbility():GetSpecialValueFor('duration')
    })

    local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge_finale.vpcf', PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 3, Vector(2,2,2))
end

modifier_ability_thief_3_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,
    CheckState 				= function(self)
    	return {
    		[MODIFIER_STATE_DISARMED] = true,
    	}
    end,

    DeclareFunctions 		= function(self)
    	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    end,
})

function modifier_ability_thief_3_delay:OnCreated()
    self.armor = self:GetAbility():GetSpecialValueFor('remove_armor')
end

function modifier_ability_thief_3_delay:GetModifierPhysicalArmorBonus()
    return -self.armor
end
