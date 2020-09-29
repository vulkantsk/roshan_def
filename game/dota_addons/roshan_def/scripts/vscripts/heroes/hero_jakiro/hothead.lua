LinkLuaModifier("modifier_jakiro_hothead", "heroes/hero_jakiro/hothead", 0)
LinkLuaModifier("modifier_jakiro_hothead_debuff", "heroes/hero_jakiro/hothead", 0)

jakiro_hothead = class({GetIntrinsicModifierName = function() return "modifier_jakiro_hothead" end})

modifier_jakiro_hothead = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER
	} end
})

function modifier_jakiro_hothead:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self.IsHotheadAttack = false
end

function modifier_jakiro_hothead:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self:GetAbility():IsCooldownReady() and not caster:PassivesDisabled() then
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_ready.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
		caster:SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf")
		self:StartIntervalThink(-1)
	end
end

function modifier_jakiro_hothead:OnAttack(keys)
	if not IsServer() then return end
	if self:GetAbility():IsCooldownReady() and keys.attacker == self:GetCaster() and not self:GetCaster():PassivesDisabled() then
		ParticleManager:DestroyParticle(self.pfx, false)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_jakiro_hothead:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self:GetAbility():IsCooldownReady() and keys.attacker == caster and not caster:PassivesDisabled() then
		local enemies_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("damage_radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)
		for _, enemy in pairs(enemies_in_radius) do
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_jakiro_hothead_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
		end

		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(pfx, 0, keys.target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("damage_radius"), 0, 0))
		ParticleManager:ReleaseParticleIndex(pfx)

		self:GetAbility():UseResources(false, false, true)
		caster:SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack.vpcf")
	end
end

modifier_jakiro_hothead_debuff = class({
	IsPurgable = function() return true end,
	GetEffectName = function() return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_jakiro_hothead_debuff:OnCreated()
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_jakiro_hothead_debuff:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("int_to_damage_pct") / 100,
		damage_type = self:GetAbility():GetAbilityDamageType()
	})
end