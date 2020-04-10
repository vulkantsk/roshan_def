
LinkLuaModifier( "modifier_lycan_open_wounds", "heroes/hero_lycan/open_wounds", LUA_MODIFIER_MOTION_NONE )

lycan_open_wounds = class({})

function lycan_open_wounds:OnSpellStart()
	local target = self:GetCursorTarget()
	local debuff_duration= self:GetSpecialValueFor("debuff_duration")
	local caster = self:GetCaster()

	target:AddNewModifier( caster, self, "modifier_lycan_open_wounds", {duration = debuff_duration} )
	target:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
end

modifier_lycan_open_wounds = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		} end,
})

function modifier_lycan_open_wounds:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end

function modifier_lycan_open_wounds:OnTakeDamage( params )
	if IsServer() then
		local Attacker = params.attacker
		local Target = params.unit
		local Ability = params.inflictor
		local flDamage = params.damage
		local ability = self:GetAbility()
		local heal_percent = ability:GetSpecialValueFor("heal_percent")/100

		if Target ~= self:GetParent() or not Target:IsAlive() or Attacker == nil or Attacker:IsBuilding() then
			return 0
		end

		if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
			return 0
		end
		if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL ) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
			return 0
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		local flLifesteal = flDamage * heal_percent
		Attacker:Heal( flLifesteal, nil )
	end
	return 0
end

function modifier_lycan_open_wounds:GetModifierMoveSpeedBonus_Percentage( )
	return self:GetAbility():GetSpecialValueFor("slow_ms")*(-1)
end
