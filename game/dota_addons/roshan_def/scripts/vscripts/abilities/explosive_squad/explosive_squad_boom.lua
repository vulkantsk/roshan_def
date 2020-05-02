
explosive_squad_boom = class({})

function explosive_squad_boom:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius')
	local damage = self:GetSpecialValueFor('damage')

	local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, nil)
	for _,unit in pairs(units) do
		DealDamage(caster, unit, damage, DAMAGE_TYPE_MAGICAL, nil, self)
	end

	caster:ForceKill(false)
	caster:EmitSound("explosive_squad_boom")
	local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_techies/techies_suicide.vpcf', PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(nfx, 1, Vector(radius/2, 0, 0))
	ParticleManager:SetParticleControl(nfx, 2, Vector(radius, 1, 1))
end
