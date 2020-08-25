modifier_ignore_movespeed_limit = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	} end,
	GetModifierIgnoreMovespeedLimit = function() return 1 end
})