LinkLuaModifier("modifier_meepo_master_shovel", "heroes/hero_meepo/master_shovel", LUA_MODIFIER_MOTION_NONE)

meepo_master_shovel = class({})

function meepo_master_shovel:GetIntrinsicModifierName()
	return "modifier_meepo_master_shovel"
end
--------------------------------------------------------
------------------------------------------------------------
modifier_meepo_master_shovel = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		} end,
})
function modifier_meepo_master_shovel:GetModifierPreAttack_CriticalStrike()
	local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
	local crit_mult = self:GetAbility():GetSpecialValueFor("crit_mult")

	if RollPercentage(crit_chance) then
		return crit_mult
	else
		return
	end
end

function modifier_meepo_master_shovel:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
				local cleave_damage = params.damage * self:GetAbility():GetSpecialValueFor("cleave_damage_pct") / 100.0
				local cleave_radius = self:GetAbility():GetSpecialValueFor("cleave_radius")
				local effect = "particles/units/heroes/hero_magnataur/magnataur_empower_cleave_effect.vpcf"
				if self:GetParent():HasModifier("modifier_meepo_digger_elixir") then
					effect = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf"
				end		
				DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleave_damage, cleave_radius, cleave_radius, cleave_radius, effect )
			end
		end
	end
end

