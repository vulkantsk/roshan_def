LinkLuaModifier("modifier_centaur_infinite_strength", "heroes/hero_centaur/infinite_strength", LUA_MODIFIER_MOTION_NONE)


centaur_infinite_strength = class({})

function centaur_infinite_strength:GetIntrinsicModifierName()
	return "modifier_centaur_infinite_strength"
end

modifier_centaur_infinite_strength = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_EVENT_ON_DEATH,
		} end,
})

function modifier_centaur_infinite_strength:GetModifierBonusStats_Strength()
	local stack_str = self:GetAbility():GetSpecialValueFor("stack_bonus_str")
	local bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str")
	return self:GetStackCount()*stack_str + bonus_str
end

--Increases the stack count of Flesh Heap.
function modifier_centaur_infinite_strength:OnDeath( data )
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local attacker = data.attacker
    local unit = data.unit

    if attacker == caster and unit and not unit:IsBuilding() and unit:GetTeam() ~= attacker:GetTeam() then
	  	self:IncrementStackCount()

		local effect = "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf"
		local pfx = ParticleManager:CreateParticle(effect, PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(pfx)

	end
end


