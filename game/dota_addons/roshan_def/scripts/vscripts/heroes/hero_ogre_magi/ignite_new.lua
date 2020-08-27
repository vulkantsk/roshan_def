LinkLuaModifier("modifier_ogre_magi_ignite_new_thinker", "heroes/hero_ogre_magi/ignite_new", 0)
LinkLuaModifier("modifier_ogre_magi_ignite_new_debuff", "heroes/hero_ogre_magi/ignite_new", 0)

ogre_magi_ignite_new = class({})

function ogre_magi_ignite_new:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

function ogre_magi_ignite_new:OnSpellStart()
	CreateModifierThinker(self:GetCaster(), self, "modifier_ogre_magi_ignite_new_thinker", {duration = self:GetSpecialValueFor("debuff_duration")}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Invoker.SunStrike.Ignite", self:GetCaster())
end

modifier_ogre_magi_ignite_new_thinker = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end
})

if IsServer() then
	function modifier_ogre_magi_ignite_new_thinker:OnCreated()
		local pfx = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetSpecialValueFor("damage_radius"), 0, 0))
		self:AddParticle(pfx, true, false, -1, false, false)

		self:StartIntervalThink(1)
		self:OnIntervalThink()

		EmitSoundOn("n_black_dragon.Fireball.Target", self:GetParent())
	end

	function modifier_ogre_magi_ignite_new_thinker:OnIntervalThink()
		local caster = self:GetCaster()

		local damage = self:GetAbility():GetSpecialValueFor("damage_per_sec") + PlayerResource:GetNetWorth(caster:GetPlayerOwnerID()) / 100 * self:GetAbility():GetSpecialValueFor("networth_to_damage_pct")

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("damage_radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)
		for _, enemy in pairs(enemies) do
			if not enemy:HasModifier("modifier_ogre_magi_ignite_new_debuff") then
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_ogre_magi_ignite_new_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
			elseif enemy:HasModifier("modifier_ogre_magi_ignite_new_debuff") and enemy:GetModifierStackCount("modifier_ogre_magi_ignite_new_debuff", caster) < self:GetAbility():GetSpecialValueFor("max_stacks") then
				enemy:SetModifierStackCount("modifier_ogre_magi_ignite_new_debuff", caster, enemy:GetModifierStackCount("modifier_ogre_magi_ignite_new_debuff", caster) + 1)
			end

			ApplyDamage({
				victim = enemy,
				attacker = caster,
				ability = self:GetAbility(),
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType()
			})
		end
	end

	function modifier_ogre_magi_ignite_new_thinker:OnDestroy()
		StopSoundEvent("n_black_dragon.Fireball.Target", self:GetParent())
	end
end

modifier_ogre_magi_ignite_new_debuff = class({
	IsPurgable = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	} end,
	GetEffectName = function() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_ogre_magi_ignite_new_debuff:OnCreated()
	self:SetStackCount(1)
end

function modifier_ogre_magi_ignite_new_debuff:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() * -self:GetAbility():GetSpecialValueFor("magic_red_per_stack")
end