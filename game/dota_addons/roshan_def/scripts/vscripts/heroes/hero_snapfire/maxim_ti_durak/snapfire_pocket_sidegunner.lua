snapfire_pocket_sidegunner = class({
	OnToggle = function(self,data)
		local bIsToggle = self:GetToggleState()
		if bIsToggle then 
			self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_snapfire_pocket', {duration = -1})
		else
			self:GetCaster():RemoveModifierByName('modifier_snapfire_pocket')
		end
	end,
	GetManaCost 	= function(self)
		local caster = self:GetCaster()
		return 25 + caster:GetMana()/100 * 2.5
	end,
})
LinkLuaModifier('modifier_snapfire_pocket', 'heroes/snapfire/snapfire_pocket_sidegunner', LUA_MODIFIER_MOTION_NONE)

modifier_snapfire_pocket = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    OnCreated 				= function(self) 
    	if IsClient() then return  end
    	self.parent = self:GetParent()
    	self.caster = self:GetCaster()
    	self.ability = self:GetAbility()
    	self.fManaPerAttack = self.ability:GetManaCost(self.ability:GetLevel())
    	self:StartIntervalThink(self.ability:GetSpecialValueFor('interval'))
    end,
	OnIntervalThink 		= function(self)
		if not self.ability:IsOwnersManaEnough() then return end
		local unit = FindUnitsInRadius(self.caster:GetTeamNumber(), 
			self.caster:GetAbsOrigin(),
			nil,
			self:GetParent():Script_GetAttackRange(),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BUILDING, 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
			FIND_CLOSEST, 
			false) 
		if #unit > 0 then 
			self.parent:ReduceMana(self.fManaPerAttack)
			self.parent:PerformAttack( unit[1], true, true, true, true, true, false, true )
		end
	end,
})