LinkLuaModifier("modifier_jakirio_ice_cage_thinker", "heroes/hero_jakiro/ice_cage", 0)
LinkLuaModifier("modifier_jakirio_ice_cage_debuff", "heroes/hero_jakiro/ice_cage", 0)

jakiro_ice_cage = class({})

function jakiro_ice_cage:OnSpellStart()
	ProjectileManager:CreateTrackingProjectile({
		EffectName = "particles/jakiro/jakiro_ice_cage_projectile.vpcf",
		Ability = self,
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		Source = self:GetCaster(),
		Target = self:GetCursorTarget(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	})
	self.hitted_enemies = {}
	EmitSoundOn("Hero_Tusk.IceShards.Cast", self:GetCaster())
end

function jakiro_ice_cage:OnProjectileThink(location)
	local enemies_in_radius = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
	for _, enemy in pairs(enemies_in_radius) do
		if not self.hitted_enemies[enemy] then
			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self,
				damage = self:GetSpecialValueFor("damage_per_sec"),
				damage_type = self:GetAbilityDamageType()
			})
			self.hitted_enemies[enemy] = true
		end
	end
end

function jakiro_ice_cage:OnProjectileHit(target, location)
	if target then
		local target_pos = target:GetAbsOrigin()
		for i = 0, 360, 36 do
			local point = target_pos + Vector(math.sin(math.rad(i)), math.cos(math.rad(i))) * self:GetSpecialValueFor("radius")
			local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_jakirio_ice_cage_thinker", {duration = self:GetSpecialValueFor("duration")}, point, self:GetCaster():GetTeamNumber(), true)
			thinker:SetHullRadius(64)
		end
		ApplyDamage({
			victim = target,
			attacker = self:GetCaster(),
			ability = self,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType()
		})
		EmitSoundOn("Hero_Tusk.IceShards.Projectile", target)
	end
end


modifier_jakirio_ice_cage_thinker = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	IsAura = function() return true end,
	GetModifierAura = function() return "modifier_jakirio_ice_cage_debuff" end
})

function modifier_jakirio_ice_cage_thinker:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_jakirio_ice_cage_thinker:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_jakirio_ice_cage_thinker:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_jakirio_ice_cage_thinker:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_jakirio_ice_cage_thinker:OnCreated()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_base.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(pfx, 0, Vector(self:GetAbility():GetSpecialValueFor("duration"), 0, 0))
	ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin())
	self:AddParticle(pfx, false, false, -1, false, false)
end


modifier_jakirio_ice_cage_debuff = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end
})

function modifier_jakirio_ice_cage_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_jakirio_ice_cage_debuff:OnIntervalThink()
	if not IsServer() then return end
	local enemies_in_radius = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)
	for _, enemy in pairs(enemies_in_radius) do
		ApplyDamage({
			victim = enemy,
			attacker = self:GetCaster(),
			ability = self:GetAbility(),
			damage = self:GetAbility():GetSpecialValueFor("damage_per_sec") / 1000,
			damage_type = self:GetAbility():GetAbilityDamageType()
		})
	end
end