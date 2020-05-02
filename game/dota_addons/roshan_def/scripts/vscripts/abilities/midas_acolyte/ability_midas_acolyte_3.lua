
ability_midas_acolyte_3 = class({})

function ability_midas_acolyte_3:GetCastRange()
	return self:GetSpecialValueFor('radius')
end

function ability_midas_acolyte_3:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius')
	local duration = self:GetSpecialValueFor('duration')
	local gold_dmg = self:GetSpecialValueFor('gold_dmg')/100
	local damage = caster:GetGoldBounty()*gold_dmg

	local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, nil)
	for _,unit in pairs(units) do
		unit:AddNewModifier(caster, self, 'modifier_stunned', {duration = duration})
		DealDamage(caster, unit, damage, DAMAGE_TYPE_MAGICAL, nil, self)
	end

	local nfx = ParticleManager:CreateParticle('particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf', PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
end
