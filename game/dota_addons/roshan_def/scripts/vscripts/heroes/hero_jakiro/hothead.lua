LinkLuaModifier("modifier_jakiro_hothead", "heroes/hero_jakiro/hothead", 0)
LinkLuaModifier("modifier_jakiro_hothead_debuff", "heroes/hero_jakiro/hothead", 0)

jakiro_hothead = class({
	GetIntrinsicModifierName = function() return "modifier_jakiro_hothead" end
})

modifier_jakiro_hothead = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ATTACK_START
	} end
})

function modifier_jakiro_hothead:GetActivityTranslationModifiers()
	if self:GetStackCount() == 0 then
		return "liquid_fire"
	end
end

function modifier_jakiro_hothead:OnAttackStart(keys)
	if keys.attacker == self:GetParent() and self:GetStackCount() == 0 then
		self:GetCaster():SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf")
	end
end


function modifier_jakiro_hothead:OnCreated()
	self:SetStackCount(self:GetAbility():GetSpecialValueFor("needed_attacks"))
	self:StartIntervalThink(FrameTime())
end

function modifier_jakiro_hothead:OnIntervalThink()
	if self:GetStackCount() < 0 then
		self:SetStackCount(0)
	elseif self:GetStackCount() > self:GetAbility():GetSpecialValueFor("needed_attacks") then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("needed_attacks"))
	end
end

function modifier_jakiro_hothead:OnAttackLanded(keys)
	if keys.attacker == self:GetParent() and self:GetParent():PassivesDisabled() == false then
		if self:GetStackCount() == 0 then
			for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self:GetSpecialValueFor("damage_radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)) do
				if not enemy:HasModifier("modifier_jakiro_hothead_debuff") then
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jakiro_hothead_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
				else
					enemy:FindModifierByName("modifier_jakiro_hothead_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("debuff_duration"), true)
				end

				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_ABSORIGIN, keys.target)
				ParticleManager:SetParticleControl(pfx, 0, keys.target:GetAbsOrigin())
				ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("damage_radius"), 0, 0))
				ParticleManager:ReleaseParticleIndex(pfx)
			end
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("needed_attacks"))
			self:GetCaster():SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack.vpcf")
		else
			self:DecrementStackCount()
		end
	end
end

modifier_jakiro_hothead_debuff = class({
	IsHidden = function() return false end,
	IsPurgable = function() return true end,
	GetEffectName = function() return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	} end
})

function modifier_jakiro_hothead_debuff:GetModifierPhysicalArmorBonus()
	return -self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_jakiro_hothead_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_jakiro_hothead_debuff:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self:GetAbility():GetSpecialValueFor("damage_per_sec"),
		damage_type = self:GetAbility():GetAbilityDamageType()
	})
end