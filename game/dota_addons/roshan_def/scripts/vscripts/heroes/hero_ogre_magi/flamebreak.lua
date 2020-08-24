LinkLuaModifier("modifier_ogre_magi_flamebreak", "heroes/hero_ogre_magi/flamebreak", 0)

ogre_magi_flamebreak = class({})

function Pracache(context)
	PrecacheResource("particle_folder", "particles/ogre_magi", context)
end

function ogre_magi_flamebreak:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

function ogre_magi_flamebreak:OnSpellStart()
	local caster = self:GetCaster()

	caster:EmitSound("Hero_Batrider.Flamebreak")
	self.projectile = ProjectileManager:CreateLinearProjectile({
		EffectName = "particles/ogre_magi/ogre_magi_flamebreak.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = (self:GetCursorPosition() - caster:GetOrigin()):Normalized() * self:GetSpecialValueFor("projectile_speed"),
		fDistance = (self:GetCursorPosition() - caster:GetOrigin()):Length2D(),
		Source = caster,
		fStartRadius = 0,
		fEndRadius = 0,
		bProvidesVision = true,
		iVisionRadius = self:GetSpecialValueFor("projectile_vision")
	})
end

function ogre_magi_flamebreak:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	if target == nil then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("damage_radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
		for _, enemy in pairs(enemies) do
			if not enemy:HasModifier("modifier_ogre_magi_flamebreak") then
				enemy:AddNewModifier(caster, self, "modifier_ogre_magi_flamebreak", {duration = self:GetSpecialValueFor("debuff_duration")})
			else
				enemy:FindModifierByName("modifier_ogre_magi_flamebreak"):SetDuration(self:GetSpecialValueFor("debuff_duration"), true)
			end

			ApplyDamage({
				victim = enemy,
				attacker = caster,
				ability = self,
				damage = self:GetSpecialValueFor("damage") + PlayerResource:GetNetWorth(caster:GetPlayerOwnerID()) / 100 * self:GetSpecialValueFor("networth_to_damage_pct"),
				damage_type = self:GetAbilityDamageType(),
			})
		end
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(pfx, 3, location)
		ParticleManager:ReleaseParticleIndex(pfx)
		EmitSoundOnLocationForAllies(location, "Hero_Batrider.Flamebreak.Impact", caster)
	end
end

modifier_ogre_magi_flamebreak = class({
	IsPurgable = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	} end,
	GetEffectName = function() return "particles/units/heroes/hero_batrider/batrider_flamebreak_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_ogre_magi_flamebreak:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_ogre_magi_flamebreak:OnIntervalThink()
	if IsServer() then
		local damage = self:GetAbility():GetSpecialValueFor("damage_per_sec") + PlayerResource:GetNetWorth(self:GetCaster():GetPlayerOwnerID()) / 100 * self:GetSpecialValueFor("networth_to_damage_per_sec_pct")
		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			ability = self:GetAbility(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType()
		})
	end
end

function modifier_ogre_magi_flamebreak:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("incoming_damage_increase")
end