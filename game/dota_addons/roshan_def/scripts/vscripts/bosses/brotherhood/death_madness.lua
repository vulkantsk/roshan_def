LinkLuaModifier("modifier_brotherhood_death_madness_buff", "bosses/brotherhood/death_madness", LUA_MODIFIER_MOTION_NONE)

if not brotherhood_death_madness then brotherhood_death_madness = class({}) end
function brotherhood_death_madness:Spawn()
	Timers:CreateTimer(0.1,function()
		local caster = self:GetCaster()
		local team = caster:GetTeam()
		local point = caster:GetAbsOrigin()
		local unit_name = "npc_dota_brotherhood_"
		self.units = {}

		for i=2,4 do
			local unit = CreateUnitByName(unit_name..i, point, true, caster, caster, team)
			table.insert(self.units, unit)
		end
	end)
end

function brotherhood_death_madness:OnOwnerDied()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local buff_duration = self:GetSpecialValueFor("buff_duration")

	for _,unit in pairs(self.units) do
		unit:AddNewModifier(caster, self, "modifier_brotherhood_death_madness_buff", nil)
	end
end

function brotherhood_death_madness:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

modifier_brotherhood_death_madness_buff = class({
	IsHidden 	= function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
	} end,
})

function modifier_brotherhood_death_madness_buff:OnCreated()
	local ability = self:GetAbility()
	self.bonus_model = ability:GetSpecialValueFor("bonus_model")
	self.bonus_as = ability:GetSpecialValueFor("bonus_as")
	self.bonus_ms = ability:GetSpecialValueFor("bonus_ms")
	self.bonus_dmg = ability:GetSpecialValueFor("bonus_dmg")

end

function modifier_brotherhood_death_madness_buff:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_brotherhood_death_madness_buff:GetModifierMoveSpeed_AbsoluteMax()
	return 1250
end

function modifier_brotherhood_death_madness_buff:GetModifierModelScale()
	return self.bonus_model
end

function modifier_brotherhood_death_madness_buff:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_brotherhood_death_madness_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_brotherhood_death_madness_buff:GetModifierDamageOutgoing_Percentage()
	return self.bonus_dmg
end
