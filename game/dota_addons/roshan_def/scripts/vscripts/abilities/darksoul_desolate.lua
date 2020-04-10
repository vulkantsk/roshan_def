LinkLuaModifier("modifier_darksoul_desolate", "abilities/darksoul_desolate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_darksoul_desolate_debuff", "abilities/darksoul_desolate", LUA_MODIFIER_MOTION_NONE)

darksoul_desolate = class({})

function darksoul_desolate:GetIntrinsicModifierName()
	return "modifier_darksoul_desolate"
end
--------------------------------------------------------
------------------------------------------------------------
modifier_darksoul_desolate = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	} end,
})

function modifier_darksoul_desolate:OnAttackLanded( params )
	if IsServer() then
		local caster = self:GetCaster()
		if params.attacker == caster and ( not caster:IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

			local target = params.target

			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not target:IsBuilding() then
				local parent = self:GetParent()
				local ability = self:GetAbility()
				local stack_duration = ability:GetSpecialValueFor("stack_duration")
				local stack_damage = ability:GetSpecialValueFor("stack_damage")
				local StackModifier = "modifier_darksoul_desolate_debuff"

				local modifier = target:AddNewModifier( caster, ability, StackModifier , { Duration = stack_duration } )
				modifier:IncrementStackCount()

				local stack_count = modifier:GetStackCount()
				local damage = stack_count * stack_damage
				DealDamage(caster, target, damage, DAMAGE_TYPE_PURE, nil, ability)
			end
		end
	end

	return 0
end

modifier_darksoul_desolate_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
})
-------------------------------------------

function modifier_darksoul_desolate_debuff:GetEffectName()
	return "particles/units/heroes/hero_spectre/spectre_desolate_debuff.vpcf"
end

function modifier_darksoul_desolate_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


