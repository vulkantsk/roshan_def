LinkLuaModifier("modifier_backdoor_protection_custom", "abilities/backdoor_protection", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_backdoor_protection_custom_buff", "abilities/backdoor_protection", LUA_MODIFIER_MOTION_NONE)

backdoor_protection_custom = class({})

function backdoor_protection_custom:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function backdoor_protection_custom:GetIntrinsicModifierName()
	return "modifier_backdoor_protection_custom"
end

modifier_backdoor_protection_custom = class({
	IsHidden				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})

function modifier_backdoor_protection_custom:CheckState()
	local state = {}
	if not self.caster:HasModifier("modifier_backdoor_protection_custom_buff") then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	return state
end

function modifier_backdoor_protection_custom:OnCreated()
	if IsServer() then
		self.ability = self:GetAbility()
		self.caster = self:GetCaster()
		self.radius 		 = self.ability:GetSpecialValueFor("radius")
		self.activation_time = self.ability:GetSpecialValueFor("activation_time")


		self:StartIntervalThink(0.03)
	end
end

function modifier_backdoor_protection_custom:OnIntervalThink()
	local caster = self.caster
	
	local units = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(),
									nil,
									self.radius,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_BASIC, 
									DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
									FIND_CLOSEST, 
									false)
	
	for _,unit in pairs(units) do
		if not unit:IsControllableByAnyPlayer() then
			caster:AddNewModifier(caster, self.ability, "modifier_backdoor_protection_custom_buff", {duration = self.activation_time})
			break
		end
	end

end

modifier_backdoor_protection_custom_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
})
