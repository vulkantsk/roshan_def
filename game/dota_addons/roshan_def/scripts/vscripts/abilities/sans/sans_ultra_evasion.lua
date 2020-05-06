backtrack_datadriven = class({})

function backtrack_datadriven:GetIntrinsicModifierName() return 'modifier_sans_shield_counter' end 
LinkLuaModifier("modifier_sans_shield_counter", 'abilities/sans/sans_ultra_evasion.lua', LUA_MODIFIER_MOTION_NONE)

modifier_sans_shield_counter = class({})

function modifier_sans_shield_counter:IsHidden() return false end

function modifier_sans_shield_counter:OnCreated()
	if IsClient() then return end

	self.proc_chance = self:GetAbility():GetLevelSpecialValueFor('proc_chance',1)
	self.attackCount = 0
	self:SetStackCount(self:GetAbility():GetLevelSpecialValueFor('max_layers',1))
end
