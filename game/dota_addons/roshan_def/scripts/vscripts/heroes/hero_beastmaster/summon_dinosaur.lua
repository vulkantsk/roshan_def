LinkLuaModifier("modifier_beastmaster_summon_dinosaur", "heroes/hero_beastmaster/summon_dinosaur", LUA_MODIFIER_MOTION_NONE)

beastmaster_summon_dinosaur = class({})

function beastmaster_summon_dinosaur:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self

	caster:EmitSound("beastmaster_beas_ability_animalsound_05")

	local player = caster:GetPlayerID()
	local team = caster:GetTeam()
	local point = caster:GetAbsOrigin()
	local fv = caster:GetForwardVector()
	local unit_name = "npc_dota_dinosaur"
	local summon_duration = ability:GetSpecialValueFor("summon_duration")

	local unit = CreateUnitByName( unit_name, point, true, caster, caster, team )
	unit:AddNewModifier( unit, ability, "modifier_phased", {duration = 0.1} )
	unit:AddNewModifier( unit, ability, "modifier_kill", {duration = summon_duration} )

	unit:SetControllableByPlayer(player, false)
	unit:SetOwner(caster)
	unit:SetForwardVector(fv)
	
end


