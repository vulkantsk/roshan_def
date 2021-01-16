LinkLuaModifier("modifier_item_snowman", "items/custom/item_snowman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_snowman_passive", "items/custom/item_snowman", LUA_MODIFIER_MOTION_NONE)


item_snowman = class({})

function item_snowman:GetIntrinsicModifierName()
	return "modifier_item_snowman_passive"
end

function item_snowman:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function item_snowman:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local killed_unit = caster
		local duration = self:GetSpecialValueFor("duration") 	

		local point = self:GetCursorPosition()
		local team = caster:GetTeam()

		local unit = CreateUnitByName( "npc_dota_item_snowman", point, true, caster, caster, team )
		unit:AddNewModifier( unit, ability, "modifier_phased", {duration = 0.1} )
		unit:AddNewModifier( unit, self, "modifier_item_snowman", {duration = duration} )
		unit:AddNewModifier( unit, self, "modifier_kill", {duration = duration} )

	end
end

function item_snowman:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) )  then
		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("damage")

		EmitSoundOn( "Frostivus.Item.Snowball.Target", hTarget )
		DealDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, nil, self)
	end
end 

modifier_item_snowman_passive = class({
	IsHidden = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}end,
})

function modifier_item_snowman_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_snowman_passive:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_snowman_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_snowman_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
end

function modifier_item_snowman_passive:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mp_regen")
end

modifier_item_snowman = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	CheckState = function() return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}end,
})

function modifier_item_snowman:OnCreated()
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")
	self.interval = ability:GetSpecialValueFor("interval")

	self:StartIntervalThink(self.interval)
end

function modifier_item_snowman:OnIntervalThink()
	local parent = self:GetParent()
	local point = parent:GetAbsOrigin()

	local enemies = parent:FindEnemyUnitsInRadius(point, self.radius, nil)
	local enemy = enemies[RandomInt(1, #enemies)]
	if enemy then	    
	    ProjectileManager:CreateTrackingProjectile({
            Target = enemy,
            Source = parent,
            Ability = self:GetAbility(),
            EffectName = "particles/econ/events/snowball/snowball_projectile.vpcf",
            bDodgeable = false,
            bProvidesVision = true,
            iMoveSpeed = 1500,
            iVisionRadius = 250,
            iVisionTeamNumber = parent:GetTeamNumber(),
        })
		EmitSoundOn( "Frostivus.Item.Snowball.Cast", parent )
    end 
end