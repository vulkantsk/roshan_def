LinkLuaModifier("modifier_hoodwink_scurry_custom", "heroes/hero_hoodwink/scurry", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hoodwink_scurry_custom_buff", "heroes/hero_hoodwink/scurry", LUA_MODIFIER_MOTION_NONE)

hoodwink_scurry_custom = class({})

function hoodwink_scurry_custom:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local duration = ability:GetSpecialValueFor("duration")
	
	local modifier = caster:AddNewModifier(caster, ability, "modifier_hoodwink_scurry_custom_buff", {duration = duration})
   
   local index = RandomInt(1, 17)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("hoodwink/hoodwink_scurry_0"..index)
    caster:EmitSound("Hero_Hoodwink.Scurry.Cast")
end

function hoodwink_scurry_custom:GetIntrinsicModifierName()
	return "modifier_hoodwink_scurry_custom"
end

--------------------------------------------------------
------------------------------------------------------------
modifier_hoodwink_scurry_custom = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_EVASION_CONSTANT} end,
})

function modifier_hoodwink_scurry_custom:GetModifierEvasion_Constant()
	local evasion = self:GetAbility():GetSpecialValueFor("evasion")
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local point = self:GetCaster():GetAbsOrigin()

	if GridNav:IsNearbyTree(point, radius, true) then
		return evasion
	end
end
--------------------------------------------------------
------------------------------------------------------------
modifier_hoodwink_scurry_custom_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
    CheckState      = function(self) return 
        {
            [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        }end,          
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		} end,
})

function modifier_hoodwink_scurry_custom_buff:OnCreated()
	self.ms_bonus = self:GetAbility():GetSpecialValueFor("movement_speed_pct")
end

function modifier_hoodwink_scurry_custom_buff:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf"
end

function modifier_hoodwink_scurry_custom_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

