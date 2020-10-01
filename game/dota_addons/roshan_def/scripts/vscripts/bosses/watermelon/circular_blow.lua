LinkLuaModifier("modifier_watermelon_tentacle_circular_blow", "bosses/watermelon/circular_blow", 0)

watermelon_tentacle_circular_blow = class({})

function watermelon_tentacle_circular_blow:GetIntrinsicModifierName()
	return "modifier_watermelon_tentacle_circular_blow"
end

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

	caster:EmitSound("Hero_Tidehunter.AnchorSmash")
	local effect = "particles/units/heroes/hero_tidehunter/tide_loadout.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_watermelon_tentacle_circular_blow = class({
	IsHidden = function(self) return true end,
	CheckState = function(self) return {
		MODIFIER_STATE_ROOTED
	}end,
})