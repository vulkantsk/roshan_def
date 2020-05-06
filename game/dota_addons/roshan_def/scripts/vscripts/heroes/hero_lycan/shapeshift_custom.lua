LinkLuaModifier("modifier_shapeshift_model_lua", "heroes/hero_lycan/modifiers/modifier_shapeshift_model_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shapeshift_bonus", "heroes/hero_lycan/modifiers/modifier_shapeshift_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_lycan_boss_shapeshift_transform", "modifiers/modifier_lycan_boss_shapeshift_transform", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lycan_boss_shapeshift", "modifiers/modifier_lycan_boss_shapeshift", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lycan_shapeshift_custom_passive", "heroes/hero_lycan/shapeshift_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lycan_shapeshift_custom", "heroes/hero_lycan/shapeshift_custom", LUA_MODIFIER_MOTION_NONE )

lycan_shapeshift_custom = class({})

function lycan_shapeshift_custom:GetBehavior()
	if self:GetCaster():HasModifier("modifier_lycan_shapeshift_custom") then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function lycan_shapeshift_custom:GetIntrinsicModifierName()
	return "modifier_lycan_shapeshift_custom_passive"
end
function lycan_shapeshift_custom:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local duration = ability:GetSpecialValueFor( "transformation_time" )
	local shapeshift_duration = ability:GetSpecialValueFor( "duration" )
--	local duration = ability:GetLevelSpecialValueFor("transformation_time", ability_level)

	EmitSoundOn( "lycan_lycan_ability_shapeshift_0"..RandomInt(1,6), caster )
	caster:AddNewModifier( caster, ability, "modifier_lycan_boss_shapeshift_transform", { Duration = duration } )

end

modifier_lycan_shapeshift_custom_passive = class({
	IsHidden = function(self) return true end,
})
function modifier_lycan_shapeshift_custom_passive:OnCreated()
	self:StartIntervalThink(0.1)
end
function modifier_lycan_shapeshift_custom_passive:OnIntervalThink()
	if IsClient() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local modifier_shapeshift = "modifier_lycan_shapeshift_custom"
	local modifier_half_shapeshift = "modifier_lycan_half_shapeshift_custom"

	if 	not caster:HasModifier("modifier_lycan_shapeshift_ultimate") then
		if not GameRules:IsDaytime() then
			if not caster:HasModifier(modifier_shapeshift) then
				caster:AddNewModifier(caster, ability, modifier_shapeshift, nil)
			end
		else
			caster:RemoveModifierByName(modifier_shapeshift)
		end
	else
		caster:AddNewModifier(caster, ability, modifier_shapeshift, nil)
	end
end

modifier_lycan_shapeshift_custom = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,

})

function modifier_lycan_shapeshift_custom:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local aura_interval = ability:GetSpecialValueFor("aura_interval")

	caster:EmitSound("lycan_lycan_ability_shapeshift_"..RandomInt(1, 6))
	caster:AddNewModifier(caster, ability, "modifier_shapeshift_model_lua", {})

	local effect = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)

	local attach_effect = "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf"
	local pfx = ParticleManager:CreateParticle(attach_effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	self:AddParticle(pfx, true, false, 100, true, false)

	self:StartIntervalThink(aura_interval)
end

function modifier_lycan_shapeshift_custom:OnDestroy()
	local caster = self:GetCaster()
	local effect = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)

	caster:RemoveModifierByName('modifier_shapeshift_model_lua')
end
function modifier_lycan_shapeshift_custom:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local point = caster:GetAbsOrigin()
	
	local duration = ability:GetSpecialValueFor("aura_interval")
	local caster_owner = caster:GetPlayerOwner() 
	local allies =  caster:FindFriendlyUnitsInRadius(point, 10000, nil)

	for _, ally in pairs(allies) do	
		local target_owner = ally:GetPlayerOwner() 
		if caster_owner == target_owner then
			ally:AddNewModifier(caster, ability, "modifier_shapeshift_bonus", {Duration = duration})
		end
	end
end


