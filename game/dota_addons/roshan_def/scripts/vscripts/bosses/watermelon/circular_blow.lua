
watermelon_tentacle_circular_blow = class({})

function  watermelon_tentacle_circular_blow:OnSpellStart()
	local caster = self:GetCaster()
	for _, nearby_enemy in pairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("damage_radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)) do
		nearby_enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
		ApplyDamage({
			victim = nearby_enemy,
			attacker = caster,
			ability = self,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType()
		})
	end
end