LinkLuaModifier("modifier_jakiro_cold_mind", "heroes/hero_jakiro/cold_mind", 0)
LinkLuaModifier("modifier_jakiro_cold_mind_debuff", "heroes/hero_jakiro/cold_mind", 0)
LinkLuaModifier("modifier_jakiro_cold_mind_freeze", "heroes/hero_jakiro/cold_mind", 0)
LinkLuaModifier("modifier_jakiro_cold_mind_cooldown", "heroes/hero_jakiro/cold_mind", 0)

jakiro_cold_mind = class({
	GetIntrinsicModifierName = function() return "modifier_jakiro_cold_mind" end
})

modifier_jakiro_cold_mind = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
	} end
})

function modifier_jakiro_cold_mind:GetModifierProcAttack_BonusDamage_Magical()
	if self:GetAbility():IsCooldownReady() and not self:GetParent():PassivesDisabled() then
		return self:GetParent():GetIntellect() / 100 * self:GetAbility():GetSpecialValueFor("int_to_damage_pct")
	end
end

function modifier_jakiro_cold_mind:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_jakiro_cold_mind:OnIntervalThink()
	if not IsServer() then return end
	if self:GetAbility():IsCooldownReady() then
		self.pfx = ParticleManager:CreateParticle("particles/jakiro/jakiro_cold_mind_ready.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_projectile.vpcf")
		self:StartIntervalThink(-1)
	end
end

function modifier_jakiro_cold_mind:OnAttack(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target
	if self:GetAbility():IsCooldownReady() and target ~= attacker and attacker == self:GetParent() and not (self:GetParent():PassivesDisabled() or target:IsBuilding()) then
		ParticleManager:DestroyParticle(self.pfx, false)
		self:StartIntervalThink(0.1)
	end
end

function modifier_jakiro_cold_mind:OnAttackLanded(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target
	local debuff = target:HasModifier("modifier_jakiro_cold_mind_debuff")
	local cooldown = target:HasModifier("modifier_jakiro_cold_mind_cooldown")
	if target and self:GetAbility():IsCooldownReady() and target ~= attacker and attacker == self:GetParent() and not (self:GetParent():PassivesDisabled() or target:IsBuilding() or target:IsOther()) then
		if not cooldown then
			if not debuff then
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_jakiro_cold_mind_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")}):IncrementStackCount()
			elseif target:FindModifierByName("modifier_jakiro_cold_mind_debuff"):GetStackCount() == self:GetAbility():GetSpecialValueFor("stack_for_freeze") - 1  then
				target:RemoveModifierByName("modifier_jakiro_cold_mind_debuff")
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_jakiro_cold_mind_freeze", {duration = self:GetAbility():GetSpecialValueFor("freeze_duration")})
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_jakiro_cold_mind_cooldown", {duration = self:GetAbility():GetCooldown(self:GetAbility():GetLevel()) + self:GetAbility():GetSpecialValueFor("freeze_duration")})
			elseif debuff then
				target:FindModifierByName("modifier_jakiro_cold_mind_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("debuff_duration"), true)
				target:FindModifierByName("modifier_jakiro_cold_mind_debuff"):IncrementStackCount()
			end
		end
		self:GetAbility():UseResources(false, false, true)
		self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack.vpcf")
	end
end


modifier_jakiro_cold_mind_debuff = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE end,
	RemoveOnDeath = function() return true end,
	GetEffectName = function() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_jakiro_cold_mind_debuff:OnCreated()
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_curse_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(self.pfx, false, false, -1, true, true)
	self:StartIntervalThink(FrameTime())
end

function modifier_jakiro_cold_mind_debuff:OnIntervalThink()
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
end


function modifier_jakiro_cold_mind_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("movement_speed_slow_pct")
end

modifier_jakiro_cold_mind_freeze = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	CheckState = function() return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true
	} end,
	GetEffectName = function() return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf" end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE} end
})

function modifier_jakiro_cold_mind_freeze:GetModifierPreAttack_Target_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("crit_damage")
end

modifier_jakiro_cold_mind_cooldown = class({
	IsPurgable = function() return false end
})
function modifier_jakiro_cold_mind_cooldown:IsHidden() return self:GetElapsedTime() >= self:GetAbility():GetSpecialValueFor("freeze_duration") end