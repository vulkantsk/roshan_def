LinkLuaModifier("modifier_boss_dive", "abilities/boss_dive", LUA_MODIFIER_MOTION_NONE)

boss_dive = class({})

function boss_dive:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	caster:SetAbsOrigin(point+Vector(0,0,-100))
end

function boss_dive:GetIntrinsicModifierName()
	return "modifier_boss_dive"
end

modifier_boss_dive = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	CheckState = function(self) return {
		[MODIFIER_STATE_ROOTED] = true,
	}end,
})

