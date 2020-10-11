LinkLuaModifier("modifier_jakiro_fire_ball_magical_reduction", "heroes/hero_jakiro/fire_ball", 0)

jakiro_fire_ball = class({})

function jakiro_fire_ball:GetAOERadius()
    return self:GetSpecialValueFor("damage_radius")
end

function jakiro_fire_ball:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local vDirection = (point - caster:GetAbsOrigin()):Normalized()
	ProjectileManager:CreateLinearProjectile({
		EffectName = "particles/jakiro/jakiro_fire_ball.vpcf",
		Abiltity = self,
		vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack2")),
		fStartRadius = 0,
		fEndRadius = 0,
		vVelocity = vDirection * self:GetSpecialValueFor("fire_ball_speed"),
		fDistance = (caster:GetAbsOrigin() - point):Length2D(),
		Source = caster,
		iUnitTargetTeam = self:GetAbilityTargetTeam(),
		iUnitTargetType = self:GetAbilityTargetType(),
		iUnitTargetFlags = self:GetAbilityTargetFlags(),
		bProvidesVision = true,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iVisionRadius = self:GetSpecialValueFor("vision_radius")
    })
end

function jakiro_fire_ball:OnProjectileHit(target, location)
	local caster = self:GetCaster()
    EmitSoundOnLocationWithCaster(location, "Hero_Batrider.Flamebreak.Impact", caster)
	if not target then
		local enemies_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("damage_radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
		PrintTable(enemies_in_radius)
		for _, enemy in pairs(enemies_in_radius) do
			local damage = self:GetSpecialValueFor("damage")

			if enemy:HasModifier("modifier_jakiro_dual_breath_new_fire") then --! Горение с 1 скилла
				damage = damage + (damage / 100 * self:GetSpecialValueFor("dual_breath_damage_amp_pct"))
				enemy:FindModifierByName("modifier_jakiro_dual_breath_new_fire"):SetDuration(enemy:FindModifierByName("modifier_jakiro_dual_breath_new_fire"):GetDuration() + self:GetSpecialValueFor("additional_duration"), true)
				enemy:AddNewModifier(caster, self, "modifier_jakiro_fire_ball_magical_reduction", {duration = self:GetSpecialValueFor("magical_reduction_duration")})
			end
			if enemy:HasModifier("modifier_jakiro_ice_ball_freeze") then --! Заморозка от Ice Ball
				damage = damage - (damage / 100 * self:GetSpecialValueFor("ice_ball_damage_reduction_pct"))
				enemy:RemoveModifierByName("modifier_jakiro_ice_ball_freeze")
			end
			ApplyDamage({
				victim = enemy,
				attacker = caster,
				ability = self,
				damage = damage,
				damage_type = self:GetAbilityDamageType()
			})
		end
	end
end

modifier_jakiro_fire_ball_magical_reduction = class({
	IsPurgable = function() return true end,
	GetEffectName = function() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
})

function modifier_jakiro_fire_ball_magical_reduction:GetModifierMagicalResistanceBonus()
	return -self:GetAbility():GetSpecialValueFor("magical_reduction_pct")
end