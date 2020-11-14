LinkLuaModifier("modifier_multicast_new", "heroes/hero_ogre_magi/multicast_new", 0)

ogre_magi_multicast_new = class({
	GetIntrinsicModifierName = function() return "modifier_multicast_new" end
})

modifier_multicast_new = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	} end
})

function modifier_multicast_new:OnAbilityFullyCast(keys)
	if IsServer() and keys.unit == self:GetCaster() and keys.ability:IsItem() == false then
		local ability = keys.ability
		local caster = self:GetCaster()

		if ability:IsItem() then 
			return
		end

		local bonus_casts = 0
		if not ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
			if RollPercentage(self:GetAbility():GetSpecialValueFor("x4_chance")) then
				bonus_casts = 3
			elseif RollPercentage(self:GetAbility():GetSpecialValueFor("x3_chance")) then
				bonus_casts = 2
			elseif RollPercentage(self:GetAbility():GetSpecialValueFor("x2_chance")) then
				bonus_casts = 1
			end
		else
			if RollPercentage(self:GetAbility():GetSpecialValueFor("x4_chance") * (1 - self:GetAbility():GetSpecialValueFor("ultimate_chance_decrease") / 100)) then
				bonus_casts = 3
			elseif RollPercentage(self:GetAbility():GetSpecialValueFor("x3_chance") * (1 - self:GetAbility():GetSpecialValueFor("ultimate_chance_decrease") / 100)) then
				bonus_casts = 2
			elseif RollPercentage(self:GetAbility():GetSpecialValueFor("x2_chance") * (1 - self:GetAbility():GetSpecialValueFor("ultimate_chance_decrease") / 100)) then
				bonus_casts = 1
			end
		end

		if bonus_casts ~= 0 then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			local bonus_cast_range_for_items = 0
			if ability:IsItem() then
				bonus_cast_range_for_items = self:GetAbility():GetSpecialValueFor("bonus_cast_range_for_items")
			end

			for bonus_casts_count = 0, bonus_casts do
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus() + bonus_cast_range_for_items, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
				for _, enemy in pairs(enemies) do
					if ability:IsHasBehavior(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
						caster:SetCursorCastTarget(enemy)
						ability:OnSpellStart()

					elseif ability:IsHasBehavior(DOTA_ABILITY_BEHAVIOR_POINT) then
						caster:SetCursorPosition(enemy:GetAbsOrigin())
						ability:OnSpellStart()

					end
					break
				end
				if ability:IsHasBehavior(DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
					ability:OnSpellStart()
				end
				ParticleManager:SetParticleControl(pfx, 1, Vector(1 + bonus_casts_count, 0, 0))
			end
		end
	end
end