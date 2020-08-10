LinkLuaModifier("modifier_bloodseeker_blood_taker", "heroes/hero_bloodseeker/blood_taker.lua", 0)

bloodseeker_blood_taker = class({GetIntrinsicModifierName = function() return "modifier_bloodseeker_blood_taker" end})

modifier_bloodseeker_blood_taker = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {MODIFIER_EVENT_ON_DEATH} end
})

function modifier_bloodseeker_blood_taker:OnDeath(keys)
	if keys.attacker == self:GetCaster() then
		keys.attacker:Heal(keys.unit:GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("heal_pct"), self:GetCaster())

		local particle = "particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_crimson_ti9_embers.vpcf"
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
		ParticleManager:SetParticleControl(pfx, 0, keys.attacker:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, keys.attacker:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end