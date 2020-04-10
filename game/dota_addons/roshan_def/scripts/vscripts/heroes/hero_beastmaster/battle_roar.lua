LinkLuaModifier("modifier_beastmaster_battle_roar", "heroes/hero_beastmaster/battle_roar", LUA_MODIFIER_MOTION_NONE)

beastmaster_battle_roar = class({})

function beastmaster_battle_roar:GetCastRange()
	return self:GetSpecialValueFor("warcry_radius")
end

function beastmaster_battle_roar:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")
	local warcry_radius = self:GetSpecialValueFor("warcry_radius")

	caster:EmitSound("Hero_Beastmaster.Primal_Roar")
	local effect = "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	
	local allies = caster:FindFriendlyUnitsInRadius(point, warcry_radius, nil)

	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_beastmaster_battle_roar", {duration = duration})
	end
end

modifier_beastmaster_battle_roar = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    Isaura                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
            MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
        } end,
})

function modifier_beastmaster_battle_roar:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_beastmaster_battle_roar:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("dmg_bonus")
end

function modifier_beastmaster_battle_roar:GetModifierIncomingPhysicalDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("resist")*(-1)
end
