LinkLuaModifier("modifier_beastmaster_summon_hawk", "heroes/hero_beastmaster/summon_hawk", LUA_MODIFIER_MOTION_NONE)

beastmaster_summon_hawk = class({})

function beastmaster_summon_hawk:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self

	caster:EmitSound("Hero_Beastmaster.Call.Boar")

	local player = caster:GetPlayerID()
	local team = caster:GetTeam()
	local point = caster:GetAbsOrigin()
	local fv = caster:GetForwardVector()
	local unit_name = "npc_dota_scout_hawk1"
	local summon_duration = ability:GetSpecialValueFor("duration")

	local unit = CreateUnitByName( unit_name, point, true, caster, caster, team )
	unit:AddNewModifier( unit, ability, "modifier_phased", {duration = 0.1} )
	unit:AddNewModifier( unit, ability, "modifier_kill", {duration = summon_duration} )

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
	
	unit:SetBaseDamageMin(base_dmg + intellegence*dmg_per_intellect )
	unit:SetBaseDamageMax(base_dmg + intellegence*dmg_per_intellect )				
	unit:SetPhysicalArmorBaseValue( agility*armor_per_agility )
	unit:SetBaseMaxHealth(base_hp+ strenght*hp_per_strenght )

	SetLevelForSubAbility(ability, "beast_master_hawk_split", unit, 1, nil)
	SetLevelForSubAbility(ability, "true_strike_datadriven", unit, 4, 1)
	local modifier = unit:AddNewModifier( unit, ability, "modifier_beastmaster_summon_hawk", nil )
	modifier:SetStackCount(agility)
--	unit:SetHealth(unit:GetMaxHealth())
--	unit:SetHealth(unit:GetMaxHealth())
end


modifier_beastmaster_summon_hawk = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}end,
})

function modifier_beastmaster_summon_hawk:GetModifierBaseAttackTimeConstant()
	local ability = self:GetAbility()
	local stack_count = self:GetStackCount()
	local summon_bat = ability:GetSpecialValueFor("summon_bat")
	local bat_agi = ability:GetSpecialValueFor("bat_per_agi")*stack_count
	local total_bat = summon_bat - bat_agi
	if total_bat <= 0.03 then
		total_bat = 0.03
	end

	return total_bat
end

