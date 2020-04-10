LinkLuaModifier( "modifier_lycan_feral_impulse_custom", "heroes/hero_lycan/feral_impulse_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lycan_feral_impulse_custom_passive", "heroes/hero_lycan/feral_impulse_custom", LUA_MODIFIER_MOTION_NONE )

lycan_feral_impulse_custom = class({})

function lycan_feral_impulse_custom:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end
function lycan_feral_impulse_custom:GetIntrinsicModifierName()
	return "modifier_lycan_feral_impulse_custom_passive"
end

modifier_lycan_feral_impulse_custom_passive = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,

})

function modifier_lycan_feral_impulse_custom_passive:OnCreated()
	local ability = self:GetAbility()
	local aura_interval = ability:GetSpecialValueFor("aura_interval")

	self:StartIntervalThink(aura_interval)
end

function modifier_lycan_feral_impulse_custom_passive:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local point = caster:GetAbsOrigin()
	
	local aura_interval = ability:GetSpecialValueFor("aura_interval")
	local aura_radius = ability:GetSpecialValueFor("aura_radius")
	local caster_owner = caster:GetPlayerOwner() 
	local allies =  caster:FindFriendlyUnitsInRadius(point, aura_radius, nil)

	for _, ally in pairs(allies) do	
		local target_owner = ally:GetPlayerOwner() 
		if caster_owner == target_owner then
			ally:AddNewModifier(caster, ability, "modifier_lycan_feral_impulse_custom", {Duration = aura_interval})
		end
	end
end

modifier_lycan_feral_impulse_custom = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}end,
})

function modifier_lycan_feral_impulse_custom:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_lycan_feral_impulse_custom:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
end
