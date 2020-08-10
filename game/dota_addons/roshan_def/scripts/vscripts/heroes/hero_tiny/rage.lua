LinkLuaModifier("modifier_tiny_rage", "heroes/hero_tiny/rage", LUA_MODIFIER_MOTION_NONE)

tiny_rage = class({})

function tiny_rage:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_tiny_rage", {duration = duration})

	caster:EmitSound("tiny_tiny_pres_t3_laugh_0"..RandomInt(1, 8))
end
--------------------------------------------------------
------------------------------------------------------------
modifier_tiny_rage = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	CheckState 				= function(self) return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}end,
	DeclareFunctions		= function(self) return 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	} end,
})

function modifier_tiny_rage:OnCreated()
    if IsClient() then return end 
    local parent = self:GetParent()
    local point = parent:GetAbsOrigin()

    local particle = "particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf"
    local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, parent)
    ParticleManager:SetParticleControlEnt(pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
    ParticleManager:SetParticleControlEnt(pfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
    ParticleManager:SetParticleControlEnt(pfx, 2, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
    ParticleManager:SetParticleControlEnt(pfx, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
    self:AddParticle(pfx, true, false, 3, true, false)
    
end 

function modifier_tiny_rage:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_tiny_rage:StatusEffectPriority()
	return 3
end

function modifier_tiny_rage:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end



