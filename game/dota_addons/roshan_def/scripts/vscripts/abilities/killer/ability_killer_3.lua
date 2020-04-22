ability_killer_3 = class({
	OnSpellStart = function(self)
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_ability_killer_3_delay', {
			duration = self:GetSpecialValueFor('delay')
		})
	end,
})

LinkLuaModifier("modifier_ability_killer_3_delay", 'abilities/killer/ability_killer_3.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_killer_3_debuff", 'abilities/killer/ability_killer_3.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_killer_3_delay = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,

    OnDestroy 				= function(self)
    	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), 'modifier_ability_killer_3_debuff', {
    		duration = self:GetAbility():GetSpecialValueFor('duration')
    	})

    	local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge_finale.vpcf', PATTACH_ABSORIGIN, self:GetParent())
    	ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
    	ParticleManager:SetParticleControl(nfx, 3, Vector(2,2,2))
    end,
})

modifier_ability_killer_3_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,

    OnCreated 				= function(self)
    	self.armor = self:GetAbility():GetSpecialValueFor('remove_armor')
    end,

    CheckState 				= function(self)
    	return {
    		[MODIFIER_STATE_DISARMED] = true,
    	}
    end,

    DeclareFunctions 		= function(self)
    	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    end,

    GetModifierPhysicalArmorBonus = function(self)
    	return -self.armor
    end,

})