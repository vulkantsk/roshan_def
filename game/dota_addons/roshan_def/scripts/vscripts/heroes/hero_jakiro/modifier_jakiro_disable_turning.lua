modifier_jakiro_disable_turning = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_DISABLE_TURNING
	} end,
	GetModifierDisableTurning = function() return 1 end
})