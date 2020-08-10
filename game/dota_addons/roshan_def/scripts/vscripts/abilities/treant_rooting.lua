LinkLuaModifier("modifier_treant_rooting", "abilities/treant_rooting", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_treant_rooting_aura", "abilities/treant_rooting", LUA_MODIFIER_MOTION_NONE)

treant_rooting = class({}) 

function treant_rooting:GetIntrinsicModifierName()
	return "modifier_treant_rooting"
end

function treant_rooting:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end
--------------------------------------------------------
------------------------------------------------------------
modifier_treant_rooting = class({
	IsHidden 				= function(self) return true end,
	IsAura 					= function(self) return true end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_treant_rooting_aura" end,
})

function modifier_treant_rooting:GetAuraRadius()
	if self:GetCaster():HasModifier("modifier_treant_recover_effect") then
		return 0
	else
		return self:GetAbility():GetSpecialValueFor("aura_radius")
	end
end

modifier_treant_rooting_aura = class({
	IsHidden 		= function(self) return false end,
   	CheckState      = function(self) return 
        {
            [MODIFIER_STATE_ROOTED] = true,          
        }end,
})

function modifier_treant_rooting_aura:OnCreated()
	local parent = self:GetParent()
	self:StartIntervalThink(1)
	parent:EmitSound("Hero_Treant.Overgrowth.Target")
end

function modifier_treant_rooting_aura:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

function modifier_treant_rooting_aura:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local damage = ability:GetSpecialValueFor("aura_dps")*self:GetStackCount()
	self:IncrementStackCount()

	DealDamage(caster, parent, damage, DAMAGE_TYPE_MAGICAL, nil, ability)


end