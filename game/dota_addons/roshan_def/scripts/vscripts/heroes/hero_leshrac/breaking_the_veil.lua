LinkLuaModifier("modifier_leshrac_breaking_the_veil_spirit_form", "heroes/hero_leshrac/breaking_the_veil", 0)

leshrac_breaking_the_veil_spirit_form = class({})

function leshrac_breaking_the_veil_spirit_form:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_leshrac_breaking_the_veil_spirit_form", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_Leshrac.Diabolic_Edict", self:GetCaster())
end


modifier_leshrac_breaking_the_veil_spirit_form = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end
})

if IsServer() then
	function modifier_leshrac_breaking_the_veil_spirit_form:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("duration") / self:GetAbility():GetSpecialValueFor("explosion_count"))
		EmitSoundOn("Hero_Leshrac.Diabolic_Edict_lp", self:GetCaster())
	end

	function modifier_leshrac_breaking_the_veil_spirit_form:OnIntervalThink()
		local radius = self:GetSpecialValueFor("radius")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_CLOSEST, false)

		for _, enemy in pairs(enemies) do
			local damage = self:GetAbility():GetSpecialValueFor("explosion_damage") * self:GetAbility():GetSpecialValueFor("spirit_form_damage_mult_pct") / 100

			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType()
			})

			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(pfx, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)

			EmitSoundOnLocationWithCaster(enemy:GetAbsOrigin(), "Hero_Leshrac.Diabolic_Edict", self:GetCaster())
		end
	end

	function modifier_leshrac_breaking_the_veil_spirit_form:OnDestroy()
		StopSoundEvent("Hero_Leshrac.Diabolic_Edict_lp", self:GetCaster())
	end
end





LinkLuaModifier("modifier_leshrac_breaking_the_veil_body_form", "heroes/hero_leshrac/breaking_the_veil", 0)

leshrac_breaking_the_veil_body_form = class({})

function leshrac_breaking_the_veil_body_form:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_leshrac_breaking_the_veil_body_form", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_Leshrac.Diabolic_Edict", self:GetCaster())
end


modifier_leshrac_breaking_the_veil_body_form = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end
})

if IsServer() then
	function modifier_leshrac_breaking_the_veil_body_form:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("duration") / self:GetAbility():GetSpecialValueFor("explosion_count"))
		EmitSoundOn("Hero_Leshrac.Diabolic_Edict_lp", self:GetCaster())
	end

	function modifier_leshrac_breaking_the_veil_body_form:OnIntervalThink()
		local radius = self:GetSpecialValueFor("radius")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_CLOSEST, false)

		for _, enemy in pairs(enemies) do
			local targets = FindUnitsInRadius(self:GetCaster():GetTeam(), enemy:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("body_form_stun_radius"), self:GetAbility():GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, self:GetAbility():GetAbilityTargetFlags(), FIND_CLOSEST, false)

			for _, target in pairs(targets) do
				if RollPercentage(self:GetAbility():GetSpecialValueFor("body_form_stun_chance")) then
					target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetSpecialValueFor("body_form_stun_duration")})
				end
			end

			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = self:GetAbility():GetSpecialValueFor("explosion_damage"),
				damage_type = self:GetAbility():GetAbilityDamageType()
			})

			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(pfx, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)

			EmitSoundOnLocationWithCaster(enemy:GetAbsOrigin(), "Hero_Leshrac.Diabolic_Edict", self:GetCaster())
		end

	end

	function modifier_leshrac_breaking_the_veil_body_form:OnDestroy()
		StopSoundEvent("Hero_Leshrac.Diabolic_Edict_lp", self:GetCaster())
	end
end