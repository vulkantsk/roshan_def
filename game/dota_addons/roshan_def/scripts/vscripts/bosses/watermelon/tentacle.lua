LinkLuaModifier("modifier_watermelon_passive", "bosses/watermelon/tentacle", 0)
require("ai/ai_watermelon")

watermelon_tentacle = class({})

function watermelon_tentacle:GetIntrinsicModifierName()
	return "modifier_watermelon_passive"
end

function watermelon_tentacle:OnSpellStart()
	local position = self:GetCursorPosition()
	local caster = self:GetCaster()

	local wm_point = FindNearestPoint(position)
	if wm_point then
		position = wm_point:GetAbsOrigin()
		if wm_point.tentacle then
			wm_point.tentacle:ForceKill(false)
		end
	end

	local unit = CreateUnitByName("npc_dota_watermelon_tentacle", position, false, caster, caster, caster:GetTeam())
	if wm_point then
		wm_point.tentacle = unit
	end
end

function watermelon_tentacle:OnOwnerDied()
	self:GetCaster():EmitSound("tidehunter_tide_death_0"..RandomInt(1, 9))
end

modifier_watermelon_passive = class({
	IsHidden = function(self) return true end,
})

function modifier_watermelon_passive:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true 
	}
	if not self:GetCaster().bInitialized then
		state[MODIFIER_STATE_DISARMED] = true
	end

	return state
end