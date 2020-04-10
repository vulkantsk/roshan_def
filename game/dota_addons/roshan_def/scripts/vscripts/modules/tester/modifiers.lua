LinkLuaModifier('modifier_max_movespeed_testers', 'modules/tester/modifiers', LUA_MODIFIER_INVALID)
modifier_max_movespeed_testers = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_MAX,MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end,
    GetModifierMoveSpeed_Max    = function(self) return 5000 end,
    GetModifierMoveSpeedBonus_Constant = function(self) return 5000 end,
})