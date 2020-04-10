snapfire_who_needs_a_weapon = class({
	OnSpellStart = function(self)

        local bonusStackWeapon = self:GetCaster():FindModifierByName('modifier_snapfire_who_needs_a_weapon_stacks')
        bonusStackWeapon = bonusStackWeapon and bonusStackWeapon:GetStackCount() or 0
        self.bonusStackWeapon = bonusStackWeapon
		self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_snapfire_who_needs_a_weapon_aura', {duration = 5})
	end,
})
LinkLuaModifier('modifier_snapfire_who_needs_a_weapon_aura', 'heroes/snapfire/snapfire_who_needs_a_weapon', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_snapfire_who_needs_a_weapon_buff', 'heroes/snapfire/snapfire_who_needs_a_weapon', LUA_MODIFIER_MOTION_NONE)

modifier_snapfire_who_needs_a_weapon_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    IsPermanent             = function(self) return true end,
    IsAura                  = function(self) return true end,
    GetAuraRadius           = function(self) return -1 end,
    GetAuraSearchTeam       = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
    GetAuraSearchFlags      = function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end,
    GetAuraSearchType       = function(self) return DOTA_UNIT_TARGET_HERO end,
    GetModifierAura         = function(self) return 'modifier_snapfire_who_needs_a_weapon_buff' end,
    OnCreated 				= function(self)
    	if IsClient() then return end
    	self.parent = self:GetParent()
    	self.parent.__bAbility_useable = true
        self.parent:RemoveModifierByName('modifier_snapfire_who_needs_a_weapon_stacks')
    end,
    OnDestroy 				= function(self)
    	if IsClient() then return end
    	self.parent.__bAbility_useable = nil
    end,
})

modifier_snapfire_who_needs_a_weapon_buff = class({
	IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    OnCreated 				= function(self)
    	if IsClient() then return end
    	self.hOwner = self:GetCaster()
  		self.hParent = self:GetParent()
  		self.ability = self:GetAbility()
        local bonusStackWeapon = self.ability.bonusStackWeapon
  		if self.hOwner == self.hParent then 
  			local amp = self.ability:GetSpecialValueFor('save_to_amp')
            print(amp * bonusStackWeapon,'1')
  			self:SetStackCount(amp * bonusStackWeapon)
  		else
  			local damage = self.ability:GetSpecialValueFor('save_to_damage')
            print(damage * bonusStackWeapon,2)
  			self:SetStackCount(damage * bonusStackWeapon)
  		end
    end,
    GetModifierPreAttack_BonusDamage = function(self) 
    	if self.hParent ~= self.hOwner then 
    		return self:GetStackCount() 
    	end
    	return 0

    end,
    GetModifierSpellAmplify_Percentage = function(self) 
    	if self.hParent == self.hOwner then 
    		return self:GetStackCount() 
    	end
    	return 0

    end,
    DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
})

modifier_snapfire_who_needs_a_weapon_stacks = class({
	IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    IsPermanent 			= function(self) return true end,
})