LinkLuaModifier( "modifier_morphling_morph_agi_custom", "heroes/hero_morphling/morph", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morphling_morph_str_custom", "heroes/hero_morphling/morph", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morphling_morph_custom", "heroes/hero_morphling/morph", LUA_MODIFIER_MOTION_NONE )

morphling_morph_custom = class({})

function morphling_morph_custom:GetIntrinsicModifierName()
	return "modifier_morphling_morph_custom"
end

morphling_morph_agi_custom = class({})

function morphling_morph_agi_custom:OnToggle()
	local caster = self:GetCaster()
	local morph_ability = caster:FindAbilityByName("morphling_morph_str_custom")
	
	if self:GetToggleState() then
		if morph_ability:GetToggleState() then
			morph_ability:ToggleAbility()
		end
		caster:AddNewModifier( caster, self, "modifier_morphling_morph_agi_custom", nil )
		EmitSoundOn("Hero_Morphling.MorphAgility", caster)
	else
		caster:RemoveModifierByName("modifier_morphling_morph_agi_custom")
		StopSoundOn("Hero_Morphling.MorphAgility", caster)
	end
end

morphling_morph_str_custom = class({})

function morphling_morph_str_custom:OnToggle()
	local caster = self:GetCaster()
	local morph_ability = caster:FindAbilityByName("morphling_morph_agi_custom")
	
	if self:GetToggleState() then
		if morph_ability:GetToggleState() then
			morph_ability:ToggleAbility()
		end
		caster:AddNewModifier( caster, self, "modifier_morphling_morph_str_custom", nil )
		EmitSoundOn("Hero_Morphling.MorphStrengh", caster)
	else
		caster:RemoveModifierByName("modifier_morphling_morph_str_custom")
		StopSoundOn("Hero_Morphling.MorphStrengh", caster)
	end
end
--------------------------------------------------------------------------------

modifier_morphling_morph_agi_custom = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
})

function modifier_morphling_morph_agi_custom:OnCreated()
	local ability = self:GetAbility()
	local morph_cooldown = ability:GetSpecialValueFor("morph_cooldown")

	self:StartIntervalThink(morph_cooldown)
end
function modifier_morphling_morph_agi_custom:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf"
end
function modifier_morphling_morph_agi_custom:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local strength = caster:GetStrength()
	local agility = caster:GetAgility()

	if caster:GetStrength() > 1 then
		caster:ModifyStrength(-1) 
		caster:ModifyAgility(1)
	end 
end
modifier_morphling_morph_str_custom = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	DeclareFunctions 		= function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}end,
})

function modifier_morphling_morph_str_custom:OnCreated()
	local ability = self:GetAbility()
	local morph_cooldown = ability:GetSpecialValueFor("morph_cooldown")

	self:StartIntervalThink(morph_cooldown)
end
function modifier_morphling_morph_str_custom:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end
function modifier_morphling_morph_str_custom:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local strength = caster:GetStrength()
	local agility = caster:GetAgility()

	if caster:GetAgility() > 1 then
		caster:ModifyAgility(-1)
		caster:ModifyStrength(1) 
	end 
end

modifier_morphling_morph_custom = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	DeclareFunctions 		= function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}end,
})

function modifier_morphling_morph_custom:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_attributes")
end

function modifier_morphling_morph_custom:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_attributes")
end

