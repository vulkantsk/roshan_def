
ability_midas_acolyte_3 = class({})
function ability_midas_acolyte_3:OnSpellStart()
	local caster = self:GetCaster()
	local dur = self:GetSpecialValueFor('duration')
	local radius = self:GetSpecialValueFor('radius')
	local units = FindUnitsInRadius(caster:GetTeamNumber(), 
	caster:GetAbsOrigin(),
	nil,
	radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_CLOSEST, 
	false)
	for k,v in pairs(units) do
		v:AddNewModifier(caster, self, 'modifier_stunned', {duration = dur})
	end
end