LinkLuaModifier("modifier_riki_summon_shadow", "heroes/hero_riki/summon_shadow", LUA_MODIFIER_MOTION_NONE)

riki_summon_shadow = class({})


function riki_summon_shadow:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self

	caster:EmitSound("riki_riki_cast_01")

	local player = caster:GetPlayerID()
	local team = caster:GetTeam()
	local point = caster:GetAbsOrigin()
	local fv = caster:GetForwardVector()
	local unit_name = "npc_riki_shadow"
	local summon_duration = ability:GetSpecialValueFor("summon_duration")

	local unit = CreateUnitByName( unit_name, point, true, caster, caster, team )
	unit:AddNewModifier( unit, ability, "modifier_phased", {duration = 0.1} )
	unit:AddNewModifier( unit, ability, "modifier_kill", {duration = summon_duration} )

	unit:SetControllableByPlayer(player, false)
	unit:SetOwner(caster)
	unit:SetForwardVector(fv)

	local hp_per_agility = ability:GetSpecialValueFor("hp_per_agility")
	local armor_per_agility = ability:GetSpecialValueFor("armor_per_agility")
	local dmg_per_agility = ability:GetSpecialValueFor("dmg_per_agility") 
	
	-- Set the unit name, concatenated with the level number
	local apm = caster:GetAttacksPerSecond()
	local bat 
	if apm > 10 then bat = 0.1 else bat = 1/apm end
	local agility = caster:GetAgility()
	local new_hp = unit:GetMaxHealth()+ agility*hp_per_agility

	unit:SetBaseDamageMin(unit:GetBaseDamageMin() + agility*dmg_per_agility )
	unit:SetBaseDamageMax(unit:GetBaseDamageMax() + agility*dmg_per_agility )				
	unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() + agility*armor_per_agility )
	unit:SetMaxHealth( new_hp )
	unit:SetBaseMaxHealth( new_hp )
	unit:SetHealth( new_hp )
	
--	unit:SetBaseAttackTime(bat)

	unit:AddNewModifier(caster, ability, "modifier_riki_summon_shadow", {shadow_bat = bat})

end

modifier_riki_summon_shadow = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}end,
})

function modifier_riki_summon_shadow:OnCreated(data)
	self:GetParent():SetRenderColor( 0, 0, 0 )
	self.shadow_bat = data.shadow_bat
end

function modifier_riki_summon_shadow:GetEffectName()
	return "particles/econ/items/riki/riki_head_ti8/riki_smokebomb_ti8_ring_debris.vpcf"
end

function modifier_riki_summon_shadow:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_riki_summon_shadow:GetModifierBaseAttackTimeConstant()
	return self.shadow_bat
end


