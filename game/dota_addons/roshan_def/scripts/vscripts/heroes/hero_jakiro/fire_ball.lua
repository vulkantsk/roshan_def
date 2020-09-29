LinkLuaModifier("modifier_jakiro_fire_ball_magical_reduction", "heroes/hero_jakiro/fire_ball", 0)

jakiro_fire_ball = class({})

function jakiro_fire_ball:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local vDirection = (point - caster:GetAbsOrigin()):Normalized()
	ProjectileManager:CreateLinearProjectile({
		EffectName = "",
		Abiltity = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fStartRadius = self:GetSpecialValueFor("start_width"),
		fEndRadius = self:GetSpecialValueFor("end_width"),
		vVelocity = self:GetSpecialValueFor("fire_ball_speed"),
		fDistance = (caster:GetAbsOrigin() - self:GetCursorPosition()):Length2D(),
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
	if not target then
		local enemies_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("damage_radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
		for _, enemy in pairs(enemies_in_radius) do
			local damage = self:GetSpecialValueFor("damage")
			local HasDualBreathModifiers = enemy:HasModifier("modifier_jakiro_dual_breath_new_ice") or enemy:HasModifier("modifier_jakiro_dual_breath_new_fire")
			local HasIceBallModifier = enemy:HasModifier("modifier_jakiro_ice_ball_freeze")
			if HasDualBreathModifiers then
				damage = damage + (damage / 100 * self:GetSpecialValueFor("dual_breath_damage_amp_pct"))
				enemy:FindModifierByName("modifier_jakiro_dual_breath_new_ice"):SetDuration(enemy:FindModifierByName("modifier_jakiro_dual_breath_new_ice"):GetDuration() * self:GetSpecialValueFor("duration_mult"), true)
				enemy:FindModifierByName("modifier_jakiro_dual_breath_new_fire"):SetDuration(enemy:FindModifierByName("modifier_jakiro_dual_breath_new_fire"):GetDuration() * self:GetSpecialValueFor("duration_mult"), true)
				enemy:AddNewModifier(caster, self, "modifier_jakiro_fire_ball_magical_reduction", {duration = self:GetSpecialValueFor("magical_reduction_duration")})
			elseif HasIceBallModifier then
				
			elseif then
			end


		end
	end
end