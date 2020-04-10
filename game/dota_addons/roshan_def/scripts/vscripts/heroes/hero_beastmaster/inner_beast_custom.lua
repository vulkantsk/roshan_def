LinkLuaModifier("modifier_beastmaster_inner_beast_custom", "heroes/hero_beastmaster/inner_beast_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beastmaster_inner_beast_custom_aura", "heroes/hero_beastmaster/inner_beast_custom", LUA_MODIFIER_MOTION_NONE)

beastmaster_inner_beast_custom = class({})

function beastmaster_inner_beast_custom:GetIntrinsicModifierName()
	return "modifier_beastmaster_inner_beast_custom"
end

modifier_beastmaster_inner_beast_custom = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	Isaura 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	IsAura 					= function(self) return true end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
	GetAuraSearchFlags 		= function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetModifierAura 		= function(self) return "modifier_beastmaster_inner_beast_custom_aura" end,
})


modifier_beastmaster_inner_beast_custom_aura = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    Isaura                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        } end,
})

function modifier_beastmaster_inner_beast_custom_aura:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_as")
end