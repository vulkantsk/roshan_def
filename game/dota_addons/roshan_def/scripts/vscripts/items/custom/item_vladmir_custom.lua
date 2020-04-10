LinkLuaModifier("modifier_item_vladmir_custom", "items/custom/item_vladmir_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_vladmir_custom_aura", "items/custom/item_vladmir_custom", LUA_MODIFIER_MOTION_NONE)

item_vladmir_custom = class({})

function item_vladmir_custom:GetCastRAnge()
	return self:GetSpecialValueFor("aura_radius")
end

function item_vladmir_custom:GetIntrinsicModifierName()
	return "modifier_item_vladmir_custom"
end

item_imba_vladmir_1 = class(item_vladmir_custom)
item_imba_vladmir_2 = class(item_vladmir_custom)
item_imba_vladmir_3 = class(item_vladmir_custom)
item_imba_vladmir_4 = class(item_vladmir_custom)

modifier_item_vladmir_custom = class({
	IsHidden 		= function(self) return true end,
	IsAura 			= function(self) return true end,
	GetAuraRadius 	= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura   = function(self) return "modifier_item_vladmir_custom_aura" end,

	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}end,
})

function modifier_item_vladmir_custom:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_vladmir_custom:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_vladmir_custom:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

modifier_item_vladmir_custom_aura = class({})

function modifier_item_vladmir_custom_aura:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_item_vladmir_custom_aura:OnCreated( kv )
	local ability = self:GetAbility()
	self.mana_regen_aura = ability:GetSpecialValueFor( "mana_regen_aura" )
	self.armor_aura = ability:GetSpecialValueFor( "armor_aura" )
	self.damage_aura = ability:GetSpecialValueFor( "damage_aura" )
	self.vampiric_aura = ability:GetSpecialValueFor( "vampiric_aura" )/100
end

function modifier_item_vladmir_custom_aura:OnRefresh( kv )
	local ability = self:GetAbility()
	self.mana_regen_aura = ability:GetSpecialValueFor( "mana_regen_aura" )
	self.armor_aura = ability:GetSpecialValueFor( "armor_aura" )
	self.damage_aura = ability:GetSpecialValueFor( "damage_aura" )
	self.vampiric_aura = ability:GetSpecialValueFor( "vampiric_aura" )/100
end

----------------------------------------

function modifier_item_vladmir_custom_aura:GetModifierConstantManaRegen()
	return self.mana_regen_aura
end

function modifier_item_vladmir_custom_aura:GetModifierPhysicalArmorBonus()
	return self.armor_aura
end

function modifier_item_vladmir_custom_aura:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage_aura
end

----------------------------------------

function modifier_item_vladmir_custom_aura:OnTakeDamage( params )
	if IsServer() then
		local Target = params.unit
		local Attacker = params.attacker
		local Ability = params.inflictor
		local flDamage = params.damage
		
		if Attacker ~= nil and Attacker == self:GetParent() and Target ~= nil and not Target:IsBuilding() and Ability == nil then
			local heal =  flDamage * self.vampiric_aura
			Attacker:Heal( heal, self:GetAbility() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
	return 0
end
