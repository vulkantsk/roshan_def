ability_midas_acolyte_3 = class({
	OnSpellStart 		= function(self)
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor('duration')
		local radius = self:GetSpecialValueFor('radius')
		local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, nil)
		for k,v in pairs(units) do
			print("gg")
			v:AddNewModifier(caster, self, 'modifier_stunned', {duration = duration})
		end

		local nfx = ParticleManager:CreateParticle('particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf', PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
	end,
})