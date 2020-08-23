LinkLuaModifier("modifier_leshrac_chain_lightning_slow", "heroes/hero_leshrac/chain_lightning", 0)


LinkLuaModifier("modifier_leshrac_chain_lightning_spirit_form_debuff", "heroes/hero_leshrac/chain_lightning", 0)
LinkLuaModifier("modifier_leshrac_chain_lightning_body_form_debuff", "heroes/hero_leshrac/chain_lightning", 0)

leshrac_chain_lightning_spirit_form = class({})

function leshrac_chain_lightning_spirit_form:OnSpellStart()
	if IsClient() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local enemies_table = {}

	if target:TriggerSpellAbsorb(self) then
		return nil
	end

	local damage = self:GetSpecialValueFor("damage")
	local bounces = self:GetSpecialValueFor("bounces") + 1

	Timers:CreateTimer(function()
		self:LaunchChainLightningOnTarget(target, damage)

		enemies_table[target:entindex()] = true

		bounces = bounces - 1

		if bounces > 0 then
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("bounce_range"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)

			for _, enemy in pairs(enemies) do
				if not enemies_table[enemy:entindex()] and enemy ~= target then
					target = enemy

					damage = damage + (damage / 100 * self:GetSpecialValueFor("damage_increase_pct"))

					return self:GetSpecialValueFor("jump_delay")
				end
			end
		end

		return nil
	end)
end

function leshrac_chain_lightning_spirit_form:LaunchChainLightningOnTarget(target, damage)
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Leshrac.Lightning_Storm", target)

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin() + Vector(0,0,2000))
	ParticleManager:SetParticleControl(pfx, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 5, target:GetAbsOrigin())

	if target:IsMagicImmune() or target:IsOutOfGame() or target:IsInvulnerable() then
		return nil
	end

	target:AddNewModifier(caster, self, "modifier_leshrac_chain_lightning_slow", {duration = self:GetSpecialValueFor("slow_duration")})
	target:AddNewModifier(caster, self, "modifier_leshrac_chain_lightning_spirit_form_debuff", {duration = self:GetSpecialValueFor("forms_debuff_duration")})

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self
	})
end


leshrac_chain_lightning_body_form = class({})

function leshrac_chain_lightning_body_form:OnSpellStart()
	if IsClient() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local enemies_table = {}

	if target:TriggerSpellAbsorb(self) then
		return nil
	end

	local damage = self:GetSpecialValueFor("damage")
	local bounces = self:GetSpecialValueFor("bounces") + 1

	Timers:CreateTimer(function()
		self:LaunchChainLightningOnTarget(target, damage)

		enemies_table[target:entindex()] = true

		bounces = bounces - 1

		if bounces > 0 then
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("bounce_range"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)

			for _, enemy in pairs(enemies) do
				if not enemies_table[enemy:entindex()] and enemy ~= target then
					target = enemy

					damage = damage + (damage / 100 * self:GetSpecialValueFor("damage_increase_pct"))

					return self:GetSpecialValueFor("jump_delay")
				end
			end
		end

		return nil
	end)
end

function leshrac_chain_lightning_body_form:LaunchChainLightningOnTarget(target, damage)
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Leshrac.Lightning_Storm", target)

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin() + Vector(0,0,2000))
	ParticleManager:SetParticleControl(pfx, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 5, target:GetAbsOrigin())

	if target:IsMagicImmune() or target:IsOutOfGame() or target:IsInvulnerable() then
		return nil
	end

	target:AddNewModifier(caster, self, "modifier_leshrac_chain_lightning_slow", {duration = self:GetSpecialValueFor("slow_duration")})
	target:AddNewModifier(caster, self, "modifier_leshrac_chain_lightning_body_form_debuff", {duration = self:GetSpecialValueFor("forms_debuff_duration")})

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self
	})
end


modifier_leshrac_chain_lightning_slow = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	} end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end
})

function modifier_leshrac_chain_lightning_slow:OnCreated()
	self.as_slow = self:GetParent():GetAttackSpeed() * self:GetAbility():GetSpecialValueFor("as_slow_pct") / 100 * -1
end

function modifier_leshrac_chain_lightning_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("ms_slow_pct")
end

function modifier_leshrac_chain_lightning_slow:GetModifierAttackSpeedBonus_Constant()
	return self.as_slow
end



modifier_leshrac_chain_lightning_spirit_form_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	} end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	GetEffectName = function() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_leshrac_chain_lightning_spirit_form_debuff:OnCreated()
	print(self:GetParent():GetMagicalArmorValue())
	self.mag_armor_red = self:GetParent():GetMagicalArmorValue() * self:GetAbility():GetSpecialValueFor("spirit_form_mag_res_reduction_pct") * -1
	print(self.mag_armor_red)
end

function modifier_leshrac_chain_lightning_spirit_form_debuff:GetModifierMagicalResistanceBonus()
	return self.mag_armor_red
end

modifier_leshrac_chain_lightning_body_form_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	} end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	GetEffectName = function() return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf" end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end
})

function modifier_leshrac_chain_lightning_body_form_debuff:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("body_form_armor_reduction_pct") / 100 * -1
end