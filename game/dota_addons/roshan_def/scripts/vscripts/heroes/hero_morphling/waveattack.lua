LinkLuaModifier("modifier_morphling_waveattack", "heroes/hero_morphling/waveattack", LUA_MODIFIER_MOTION_NONE)

morphling_waveattack = class({})

function morphling_waveattack:GetIntrinsicModifierName()
	return "modifier_morphling_waveattack"
end 

function morphling_waveattack:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
    if hTarget then 
		local damage = self:GetSpecialValueFor("damage")
		DealDamage(caster, hTarget, damage, self:GetAbilityDamageType(), nil, self)
    	return 
    end
end 

modifier_morphling_waveattack = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_ATTACK,
	}end,
})

function modifier_morphling_waveattack:OnAttack(data)
	local caster = self:GetCaster()
	local attacker = data.attacker
	local target = data.target

	if caster == attacker and target and not target:IsMagicImmune() then
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor("radius")
		local bonus_length = ability:GetSpecialValueFor("bonus_length")
		local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
		if not RollPercentage(trigger_chance) then
			return
		end
		local vDirection = target:GetOrigin() - caster:GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		local info = {
			EffectName = 'particles/units/heroes/hero_morphling/morphling_waveform.vpcf',
			Ability = ability,
			vSpawnOrigin = caster:GetOrigin(), 
			fStartRadius = radius,
			fEndRadius = radius,
			vVelocity = vDirection * 1200,
			fDistance = #(target:GetOrigin() - caster:GetOrigin())+bonus_length, -- transform 2D
			Source = caster,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}

		ProjectileManager:CreateLinearProjectile( info )
	    EmitSoundOn("Hero_Morphling.Waveform", caster)		
	end
end