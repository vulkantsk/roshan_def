LinkLuaModifier("modifier_hoodwink_inner_fire", "heroes/hero_hoodwink/inner_fire", LUA_MODIFIER_MOTION_NONE)

if not hoodwink_inner_fire then
	hoodwink_inner_fire = class({})
end
if IsServer() then
	function hoodwink_inner_fire:OnSpellStart()
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		
		caster:AddNewModifier(caster, self, "modifier_hoodwink_inner_fire", {duration = duration})

	    local index = RandomInt(1, 21)
	    if index < 10 then
	        index = "0"..index
	    end
	    caster:EmitSound("hoodwink_hoodwink_arbalest_"..index)
	end
end

modifier_hoodwink_inner_fire = class({
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}end,
})

function modifier_hoodwink_inner_fire:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end
function modifier_hoodwink_inner_fire:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_as")
end
