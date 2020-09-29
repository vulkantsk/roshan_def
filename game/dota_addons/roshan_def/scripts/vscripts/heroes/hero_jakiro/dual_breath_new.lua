 LinkLuaModifier("modifier_jakiro_disable_turning", "heroes/hero_jakiro/modifier_jakiro_disable_turning", 0)
 LinkLuaModifier("modifier_jakiro_dual_breath_new_ice", "heroes/hero_jakiro/dual_breath_new", 0)
 LinkLuaModifier("modifier_jakiro_dual_breath_new_fire", "heroes/hero_jakiro/dual_breath_new", 0)

 jakiro_dual_breath_new = class({})

 function jakiro_dual_breath_new:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	ProjectileManager:CreateLinearProjectile({
		EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_ice.vpcf",
		Ability = self,
		Source = caster,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = (point - caster:GetOrigin()):Normalized() * self:GetSpecialValueFor("speed"),
		fDistance = self:GetCastRange(caster:GetAbsOrigin(), caster),
		fStartRadius = self:GetSpecialValueFor("start_radius"),
		fEndRadius = self:GetSpecialValueFor("end_radius"),
		iUnitTargetTeam = self:GetAbilityTargetTeam(),
		iUnitTargetType = self:GetAbilityTargetType(),
		iUnitTargetFlags = self:GetAbilityTargetFlags(),
		bIgnoreSource = true,
		ExtraData = {
			projectile_type = "ice"
		}
	})
	EmitSoundOn("Hero_Jakiro.DualBreath.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_jakiro_disable_turning", {duration = self:GetSpecialValueFor("fire_delay")})

	self:GetCaster():SetContextThink(DoUniqueString("jakiro_dual_breath_new"), function()
		ProjectileManager:CreateLinearProjectile({
			EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_fire.vpcf",
			Ability = self,
			Source = caster,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = (point - caster:GetOrigin()):Normalized() * self:GetSpecialValueFor("speed"),
			fDistance = self:GetCastRange(caster:GetAbsOrigin(), caster),
			fStartRadius = self:GetSpecialValueFor("start_radius"),
			fEndRadius = self:GetSpecialValueFor("end_radius"),
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetType = self:GetAbilityTargetType(),
			iUnitTargetFlags = self:GetAbilityTargetFlags(),
			bIgnoreSource = true,
			ExtraData = {
				projectile_type = "fire"
			}
		})
		EmitSoundOn("Hero_Jakiro.DualBreath.Cast", caster)
		caster:AddNewModifier(caster, self, "modifier_jakiro_disable_turning", {duration = self:GetSpecialValueFor("fire_delay")})
	end, self:GetSpecialValueFor("fire_delay"))
end

function jakiro_dual_breath_new:OnProjectileHit_ExtraData(target, location, ExtraData)
	local caster = self:GetCaster()
	if target then
		if ExtraData.projectile_type == "ice" then
			target:AddNewModifier(caster, self, "modifier_jakiro_dual_breath_new_ice", {duration = self:GetSpecialValueFor("debuff_duration")})
		elseif ExtraData.projectile_type == "fire" then
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = self,
				damage = self:GetSpecialValueFor("damage"),
				damage_type = self:GetAbilityDamageType()
			})
			target:AddNewModifier(caster, self, "modifier_jakiro_dual_breath_new_fire", {duration = self:GetSpecialValueFor("debuff_duration")})
			EmitSoundOn("Hero_Jakiro.DualBreath.Burn", target)
		end
	end
end

modifier_jakiro_dual_breath_new_ice = class({
	IsHidden = function() return false end,
	IsPurgable = function() return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	} end
})

function modifier_jakiro_dual_breath_new_ice:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow_movement_speed_pct")
end

function modifier_jakiro_dual_breath_new_ice:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("slow_attack_speed")
end



modifier_jakiro_dual_breath_new_fire = class({
	IsHidden = function() return false end,
	IsPurgable = function() return true end,
	GetEffectName = function() return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end
})

function modifier_jakiro_dual_breath_new_fire:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_jakiro_dual_breath_new_fire:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self:GetAbility():GetSpecialValueFor("burn_damage"),
		damage_type = self:GetAbility():GetAbilityDamageType()
	})
end