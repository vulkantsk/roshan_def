LinkLuaModifier("modifier_beastmaster_summon_boar", "heroes/hero_beastmaster/summon_boar", LUA_MODIFIER_MOTION_NONE)

beastmaster_summon_boar = class({})

function beastmaster_summon_boar:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self

	caster:EmitSound("Hero_Beastmaster.Call.Boar")

	local player = caster:GetPlayerID()
	local team = caster:GetTeam()
	local point = caster:GetAbsOrigin()
	local fv = caster:GetForwardVector()
	local unit_name = "npc_dota_beastmaster_boar_1"
	local summon_duration = ability:GetSpecialValueFor("duration")

	local unit = CreateUnitByName( unit_name, point, true, caster, caster, team )
	unit:AddNewModifier( unit, ability, "modifier_phased", {duration = 0.1} )
	unit:AddNewModifier( unit, ability, "modifier_kill", {duration = summon_duration} )
	unit:AddNewModifier( unit, ability, "modifier_beastmaster_summon_boar", nil )

	unit:SetControllableByPlayer(player, false)
	unit:SetOwner(caster)
	unit:SetForwardVector(fv)

	local armor_per_agility = ability:GetSpecialValueFor("armor_per_agi")
	local dmg_per_intellect = ability:GetSpecialValueFor("dmg_per_int")
	local hp_per_strenght = ability:GetSpecialValueFor("hp_per_str") 

	local strenght = caster:GetStrength()
	local agility = caster:GetAgility()
	local intellegence = caster:GetIntellect()

	local base_hp = ability:GetSpecialValueFor("summon_hp")
	local base_dmg = ability:GetSpecialValueFor("summon_dmg")
	local bat = ability:GetSpecialValueFor("summon_bat")
	
	unit:SetBaseDamageMin(base_dmg + intellegence*dmg_per_intellect )
	unit:SetBaseDamageMax(base_dmg + intellegence*dmg_per_intellect )				
	unit:SetPhysicalArmorBaseValue( agility*armor_per_agility )
	unit:SetBaseMaxHealth(base_hp+ strenght*hp_per_strenght )

	SetLevelForSubAbility(ability, "beastmaster_boar_crit", unit, 1, nil)
	SetLevelForSubAbility(ability, "true_strike_datadriven", unit, 7, 1)
--	unit:SetHealth(unit:GetMaxHealth())
--	unit:SetHealth(unit:GetMaxHealth())
end


modifier_beastmaster_summon_boar = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}end,
})

function modifier_beastmaster_summon_boar:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("summon_bat")
end
