ogre_magi_fireblast_new = class({})

function ogre_magi_fireblast_new:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) then return end

	local damage = self:GetSpecialValueFor("damage") + PlayerResource:GetNetWorth(caster:GetPlayerOwnerID()) / 100 * self:GetSpecialValueFor("networth_to_damage_pct")
	local bounces = self:GetSpecialValueFor("bounces")

	local IsFirstTarget = true

	EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", caster)

	Timers:CreateTimer(function()
		self:LaunchFireblast(target, IsFirstTarget, damage)
		IsFirstTarget = false

		bounces = bounces - 1

		if bounces > 0 then
			local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("bounce_range"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)

			for _, enemy in pairs(nearby_enemies) do
				target = enemy
				return 0.4
			end
		end
	end)

	return nil
end

function ogre_magi_fireblast_new:LaunchFireblast(target, IsFirstTarget, damage)
	local caster = self:GetCaster()

	if not IsFirstTarget then
		damage = damage / 2
	end

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)

	target:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self
	})

	EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
end