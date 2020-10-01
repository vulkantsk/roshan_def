LinkLuaModifier("modifier_watermelon_madness", "bosses/watermelon/madness", 0)

watermelon_madness = class({})

function watermelon_madness:OnSpellStart()
  local duration = self:GetSpecialValueFor("duration")
  local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_watermelon_madness", {duration = duration})

	self:GetCaster():EmitSound("tidehunter_tide_ability_ravage_0"..RandomInt(1, 2))	
end

modifier_watermelon_madness = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return true end,
})
