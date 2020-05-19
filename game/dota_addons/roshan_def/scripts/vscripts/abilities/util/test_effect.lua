LinkLuaModifier("modifier_test_effect", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_1", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_2", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_3", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_4", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_5", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_6", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_7", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_8", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_9", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_10", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_11", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_effect_12", "abilities/util/test_effect", LUA_MODIFIER_MOTION_NONE)

test_effect = class({})

function test_effect:OnSpellStart()
	local effects = {
		"",
		"particles/econ/items/effigies/status_fx_effigies/status_effect_statue_compendium_2014_radiant.vpcf",
		"particles/status_fx/status_effect_statue.vpcf",
		"particles/status_fx/status_effect_statue_compendium_2014_dire.vpcf",
		"particles/status_fx/status_effect_statue_compendium_2014_radiant.vpcf",
		"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold.vpcf",
		"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone.vpcf",
		"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone_dire.vpcf",
		"particles/econ/items/effigies/status_fx_effigies/status_effect_vr_desat_stone.vpcf",
		"particles/status_fx/status_effect_medusa_stone_gaze.vpcf",
		"particles/units/heroes/hero_medusa/status_effect_medusa_stone_gaze_backup.vpcf",
		"particles/econ/items/slardar/slardar_takoyaki_gold/status_effect_slardar_crush_tako_gold.vpcf"
	}
	local caster = self:GetCaster()

	if self.index then
		caster:RemoveModifierByName("modifier_test_effect_"..self.index)
	end

	if self.index == nil or self.index == #effects then
		self.index = 1
	else
		self.index = self.index + 1
	end
	local effect = effects[self.index]
	print("effect = "..effect)

	caster:AddNewModifier( caster, self, "modifier_test_effect", nil)
	local buff_modifier = caster:AddNewModifier( caster, self, "modifier_test_effect_"..self.index, nil)


--	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
--	ParticleManager:ReleaseParticleIndex(pfx)
--	buff_modifier:AddParticle(pfx, true, true, 100, false, false)


end
--------------------------------------------------------
------------------------------------------------------------

modifier_test_effect = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	CheckState = function(self) return {
		[MODIFIER_STATE_FROZEN] = true,
	}end,
})

modifier_test_effect_1 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_1:GetStatusEffectName()
	return ""
end

modifier_test_effect_2 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_2:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_statue_compendium_2014_radiant.vpcf"
end

modifier_test_effect_3 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_3:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

modifier_test_effect_4 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_4:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue_compendium_2014_dire.vpcf"
end

modifier_test_effect_5 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_5:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue_compendium_2014_radiant.vpcf"
end

modifier_test_effect_6 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_6:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold.vpcf"
end

modifier_test_effect_7 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_7:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone.vpcf"
end

modifier_test_effect_8 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_8:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone_dire.vpcf"
end

modifier_test_effect_9 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_9:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_vr_desat_stone.vpcf"
end

modifier_test_effect_10 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_10:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

modifier_test_effect_11 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_11:GetStatusEffectName()
	return "particles/units/heroes/hero_medusa/status_effect_medusa_stone_gaze_backup.vpcf"
end

modifier_test_effect_12 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})

function modifier_test_effect_12:GetStatusEffectName()
	return "particles/econ/items/slardar/slardar_takoyaki_gold/status_effect_slardar_crush_tako_gold.vpcf"
end

		
