LinkLuaModifier("modifier_hoodwink_hunter_skill", "heroes/hero_hoodwink/hunter_skill", LUA_MODIFIER_MOTION_NONE)

if not hoodwink_hunter_skill then
	hoodwink_hunter_skill = class({})
end
if IsServer() then
	function hoodwink_hunter_skill:GetIntrinsicModifierName()
		return "modifier_hoodwink_hunter_skill"
	end
end

modifier_hoodwink_hunter_skill = class({
 	IsHidden = function() return true end,
})


if IsServer() then
	function modifier_hoodwink_hunter_skill:DeclareFunctions()
		return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
	end
	function modifier_hoodwink_hunter_skill:GetModifierPreAttack_CriticalStrike()
		local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
		local crit_mult = self:GetAbility():GetSpecialValueFor("crit_mult")
		local caster = self:GetCaster()
		
		if RollPercentage(crit_chance) then
			return crit_mult
		end
	end
end
