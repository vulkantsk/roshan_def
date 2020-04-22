LinkLuaModifier("modifier_ability_midas_acolyte_2_aura", 'abilities/midas_acolyte/ability_midas_acolyte_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_midas_acolyte_2_debuff", 'abilities/midas_acolyte/ability_midas_acolyte_2.lua', LUA_MODIFIER_MOTION_NONE)

ability_midas_acolyte_2 = class({})

function ability_midas_acolyte_2:GetIntrinsicModifierName()
	return 'modifier_ability_midas_acolyte_2_aura'
end

modifier_ability_midas_acolyte_2_aura = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
})

function modifier_ability_midas_acolyte_2_aura:OnCreated()
	local ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.radius = ability:GetSpecialValueFor('aura_radius')
	self.heal = ability:GetSpecialValueFor('heal')
	self.damage = ability:GetSpecialValueFor('damage')
	self.gold_steal = ability:GetSpecialValueFor('gold_steal')

	self:StartIntervalThink(1)
end

function modifier_ability_midas_acolyte_2_aura:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self.caster
	local point = caster:GetAbsOrigin()
	local enemies = caster:FindEnemyUnitsInRadius(point, self.radius, nil)
	for _,enemy in pairs(enemies) do
		if enemy:IsRealHero() then
			local hero_gold = enemy:GetGold()
			if self.gold_steal > hero_gold then return end
			print(hero_gold)
			print(self.gold_steal)

			DealDamage(caster, enemy, self.damage, DAMAGE_TYPE_PURE, nil, ability)
			caster:Heal(self.heal, ability)

			local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)	
			ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
			ParticleManager:ReleaseParticleIndex(midas_particle)

			local gold = caster:GetGoldBounty() + self.gold_steal
			caster:SetMaximumGoldBounty(gold)
			caster:SetMinimumGoldBounty(gold)

			enemy:ModifyGold(-self.gold_steal, false, 0)

		end
	end
end