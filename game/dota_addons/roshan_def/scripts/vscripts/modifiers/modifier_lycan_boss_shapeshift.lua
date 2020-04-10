LinkLuaModifier( "modifier_lycan_boss_shapeshift_crit_buff", "modifiers/modifier_lycan_boss_shapeshift", LUA_MODIFIER_MOTION_NONE )


modifier_lycan_boss_shapeshift = class({})

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:OnCreated( kv )	
	if IsServer() then
		
		self.speed = self:GetAbility():GetSpecialValueFor( "halfspeed" )
		self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
		self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )
		
			self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( self.nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( self.nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_tail", self:GetParent():GetOrigin(), true )

			self.nPortraitFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_shapeshift_portrait.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( self.nPortraitFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_mouth", self:GetParent():GetOrigin(), true )
			ParticleManager:SetParticleControlEnt( self.nPortraitFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_upper_jaw", self:GetParent():GetOrigin(), true )

	end
end

function modifier_lycan_boss_shapeshift:GetEffectName()
    return "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf"
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:OnDestroy()
	if IsServer() then
		ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() ) )
		if self.nFXIndex ~= nil then ParticleManager:DestroyParticle(self.nFXIndex,true) end
		if self.nPortraitFXIndex ~= nil then ParticleManager:DestroyParticle(self.nPortraitFXIndex,true) end
	end
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}

	return funcs
end

function modifier_lycan_boss_shapeshift:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(self.crit_chance) then
		return self.crit_multiplier
	end
end
--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:GetModifierModelChange( params )
	return "models/creeps/knoll_1/werewolf_boss.vmdl"
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:GetActivityTranslationModifiers( params )
	return "shapeshift"
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:GetModifierModelScale( params )
	return 60
end

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:GetModifierMoveSpeedBonus_Constant( params )
	return self:GetAbility():GetSpecialValueFor( "halfspeed" )
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

function modifier_lycan_boss_shapeshift:GetModifierAttackPointConstant( params )
	return 0.23
end

