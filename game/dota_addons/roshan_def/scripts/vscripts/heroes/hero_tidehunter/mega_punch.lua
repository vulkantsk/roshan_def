LinkLuaModifier("modifier_tidehunter_mega_punch", "heroes/hero_tidehunter/mega_punch", LUA_MODIFIER_MOTION_NONE)

tidehunter_mega_punch = class({})

function tidehunter_mega_punch:GetIntrinsicModifierName()
	return "modifier_tidehunter_mega_punch"
end

modifier_tidehunter_mega_punch = class({
	IsHidden 		= function(self) return true end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}end,
})

function modifier_tidehunter_mega_punch:OnCreated( kv )
	self.ability = self:GetAbility()
	self.crit_min = self.ability:GetSpecialValueFor( "crit_min" )
	self.crit_max = self.ability:GetSpecialValueFor( "crit_max" )
	self.lifesteal = self.ability:GetSpecialValueFor( "lifesteal" )

end

function modifier_tidehunter_mega_punch:OnRefresh( kv )
	self:OnCreated(kv)
end

----------------------------------------
----------------------------------------
function modifier_tidehunter_mega_punch:GetModifierPreAttack_CriticalStrike(data)
	if IsServer() and (not self:GetParent():PassivesDisabled()) and self.ability:IsCooldownReady() then
 		return RandomInt(self.crit_min, self.crit_max)
	end
end

function modifier_tidehunter_mega_punch:OnAttackLanded(data)
	local parent = self:GetParent()
	local attacker = data.attacker
	local target = data.target

	if parent==attacker and not parent:PassivesDisabled() and self.ability:IsCooldownReady() and target:IsAlive() and target:GetTeam() ~= attacker:GetTeam() then
    	self.record = data.record
        self.ability:UseResources(true, true, true)
        EmitSoundOn( "Hero_ChaosKnight.ChaosStrike", parent )
	end
end

function modifier_tidehunter_mega_punch:OnTakeDamage( data )
	if IsServer() then
		if self.record and data.record == self.record then
			local parent = self:GetParent()
			local heal = data.damage * self.lifesteal/100
			parent:Heal( heal, self.ability )
--            self.record = nil
            local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
            ParticleManager:ReleaseParticleIndex(effect_cast)

		end
	end
end
