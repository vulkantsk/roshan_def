LinkLuaModifier("modifier_sleight_of_fist_target_datadriven", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sleight_of_fist_target_hero_datadriven", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sleight_if_fist_target_creep_datadriven", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sleight_of_fist_caster_datadriven", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sleight_of_fist_dummy_datadriven", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_sleight_of_fist_debuff_attackspeed", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sleight_of_fist_debuff_movespeed", 'abilities/killer/ability_killer_2.lua', LUA_MODIFIER_MOTION_NONE)

ability_killer_2 = class({
	OnSpellStart = function(self)
	local keys = {
		caster = self:GetCaster(),
		target_point = self:GetCursorPosition(),
		ability = self,
	}
	if keys.caster.sleight_of_fist_active ~= nil and keys.caster.sleight_of_fist_action == true then
		keys.ability:RefundManaCost()
		return nil
	end

	-- Inheritted variables
	local caster = keys.caster
	local targetPoint = keys.target_point
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local attack_interval = ability:GetLevelSpecialValueFor( "attack_interval", ability:GetLevel() - 1 )
	local modifierTargetName = "modifier_sleight_of_fist_target_datadriven"
	local modifierHeroName = "modifier_sleight_of_fist_target_hero_datadriven"
	local modifierCreepName = "modifier_sleight_if_fist_target_creep_datadriven"
	local casterModifierName = "modifier_sleight_of_fist_caster_datadriven"
	local dummyModifierName = "modifier_sleight_of_fist_dummy_datadriven"
	local particleSlashName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"
	local particleTrailName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf"
	local particleCastName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
	local slashSound = "Hero_EmberSpirit.SleightOfFist.Damage"
	
	-- Targeting variables
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	local unitOrder = FIND_ANY_ORDER
	
	-- Necessary varaibles
	local counter = 0
	caster.sleight_of_fist_active = true
	local dummy = CreateUnitByName( caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
	dummy:AddNewModifier(caster, ability, dummyModifierName, {duration = -1})
	caster:AddNewModifier(caster, ability, 'modifier_sleight_of_fist_caster_datadriven', {duration = -1})


	-- Casting particles
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( castFxIndex, 0, targetPoint )
	ParticleManager:SetParticleControl( castFxIndex, 1, Vector( radius, 0, 0 ) )
	
	Timers:CreateTimer( 0.1, function()
			ParticleManager:DestroyParticle( castFxIndex, false )
			ParticleManager:ReleaseParticleIndex( castFxIndex )
		end
	)
	
	-- Start function
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), targetPoint, caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)
	
	for _, target in pairs( units ) do
		counter = counter + 1
		target:AddNewModifier( caster, ability, modifierTargetName, {} )
		Timers:CreateTimer( counter * attack_interval, function()
				-- Only jump to it if it's alive
				if target:IsAlive() then
					-- Create trail particles
					local trailFxIndex = ParticleManager:CreateParticle( particleTrailName, PATTACH_CUSTOMORIGIN, target )
					ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )
					ParticleManager:SetParticleControl( trailFxIndex, 1, caster:GetAbsOrigin() )
					
					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( trailFxIndex, false )
							ParticleManager:ReleaseParticleIndex( trailFxIndex )
							return nil
						end
					)
					
					-- Move hero there
					FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
					
					if target:IsHero() then
						caster:AddNewModifier( caster, ability, modifierHeroName, {} )
					else
						caster:AddNewModifier( caster, ability, modifierCreepName, {} )
					end
					
					caster:PerformAttack(target, true, true, true, false, true, false, true)
					
					-- Slash particles
					local slashFxIndex = ParticleManager:CreateParticle( particleSlashName, PATTACH_ABSORIGIN_FOLLOW, target )
					StartSoundEvent( slashSound, caster )
					
					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( slashFxIndex, false )
							ParticleManager:ReleaseParticleIndex( slashFxIndex )
							StopSoundEvent( slashSound, caster )
							return nil
						end
					)
					
					-- Clean up modifier
					caster:RemoveModifierByName( modifierHeroName )
					caster:RemoveModifierByName( modifierCreepName )
					target:RemoveModifierByName( modifierTargetName )
				end
				return nil
			end
		)
	end
	
	-- Return caster to origin position
	Timers:CreateTimer( ( counter + 1 ) * attack_interval, function()
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			dummy:RemoveSelf()
			caster:RemoveModifierByName( casterModifierName )
			caster.sleight_of_fist_active = false
			return nil
		end
	)
	end,
})

modifier_sleight_of_fist_dummy_datadriven = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return true end,
    GetEffectName 			= function(self) return 'particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf' end,
    GetEffectAttachType 	= function(self) return PATTACH_CUSTOMORIGIN end,
    CheckState 				= function(self)
    	return {
	    	[MODIFIER_STATE_INVULNERABLE]					= true,
			[MODIFIER_STATE_NO_HEALTH_BAR]					= true,
			[MODIFIER_STATE_NO_UNIT_COLLISION]				= true,
			[MODIFIER_STATE_NOT_ON_MINIMAP]					= true,
			[MODIFIER_STATE_UNSELECTABLE]					= true,
			[MODIFIER_STATE_COMMAND_RESTRICTED]				= true,
			[MODIFIER_STATE_DISARMED]						= true,
			[MODIFIER_STATE_OUT_OF_GAME] 					= true,
			[MODIFIER_STATE_PROVIDES_VISION] 				= true,

   	 	}
  	end,
})

modifier_sleight_of_fist_caster_datadriven = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return true end,
    CheckState 				= function(self)
      return {
			[MODIFIER_STATE_NO_HEALTH_BAR]					= true,
			[MODIFIER_STATE_NO_UNIT_COLLISION]				= true,
			[MODIFIER_STATE_UNSELECTABLE]					= true,
			[MODIFIER_STATE_ROOTED]							= true,
			[MODIFIER_STATE_INVULNERABLE]					= true,
			[MODIFIER_STATE_OUT_OF_GAME] 					= true,
   	 	}
  	end, 
  	DeclareFunctions 		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
  	OnCreated = function(self)
 		self.parent = self:GetParent()
 		self.ability = self:GetAbility()
 		self.movespeed = self.ability:GetSpecialValueFor('reduction_movespeed')
 		self.attack_speed = self.ability:GetSpecialValueFor('reduction_atkspeed')
 		self.reduction_duration = self.ability:GetSpecialValueFor('reduction_duration')
  	end, 
  	OnAttackLanded 			= function(self,data)
  		if data.attacker == self.parent then 
			data.target:AddStackModifier({
				ability = self.ability,
				modifier = 'modifier_sleight_of_fist_debuff_movespeed',
				count = self.movespeed,
				caster = data.attacker,
				duration = self.reduction_duration,
			})
			data.target:AddStackModifier({
				ability = self.ability,
				modifier = 'modifier_sleight_of_fist_debuff_attackspeed',
				count = self.attack_speed,
				caster = data.attacker,
				duration = self.reduction_duration,
			})
  		end
  	end, 
})

modifier_sleight_of_fist_debuff_movespeed = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end,
	GetModifierMoveSpeedBonus_Constant = function(self) return -self:GetStackCount() end,
})

modifier_sleight_of_fist_debuff_attackspeed = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end,
	GetModifierAttackSpeedBonus_Constant = function(self) return -self:GetStackCount() end,
})
modifier_sleight_of_fist_target_hero_datadriven = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
	GetModifierPreAttack_BonusDamage = function(self) return self:GetStackCount() end,   
})

modifier_sleight_if_fist_target_creep_datadriven = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end,
	GetModifierDamageOutgoing_Percentage = function(self) return -self:GetStackCount() end,   
})

modifier_sleight_of_fist_target_datadriven = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return true end,
    GetEffectName 			= function(self) return 'particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf' end,
    GetEffectAttachType 	= function(self) return PATTACH_OVERHEAD_FOLLOW end,  
})
