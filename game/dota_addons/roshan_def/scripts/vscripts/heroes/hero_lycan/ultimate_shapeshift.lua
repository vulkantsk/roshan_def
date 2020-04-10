LinkLuaModifier( "modifier_lycan_shapeshift_ultimate", "heroes/hero_lycan/ultimate_shapeshift", LUA_MODIFIER_MOTION_NONE )

lycan_ultimate_shapeshift = class({})

function lycan_ultimate_shapeshift:GetIntrinsicModifierName()
	return "modifier_lycan_shapeshift_ultimate"
end

function lycan_ultimate_shapeshift:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local point = caster:GetAbsOrigin()
	
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	local allies =  caster:FindFriendlyUnitsInRadius(point, radius, nil)

	for _, ally in pairs(allies) do
		print(ally:GetUnitName())	
		ally:AddNewModifier(caster, ability, "modifier_shapeshift_bonus", {Duration = duration})
	end
end

modifier_lycan_shapeshift_ultimate = class({
	IsHidden = function(self) return true end,
})

