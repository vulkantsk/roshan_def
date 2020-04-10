LinkLuaModifier("modifier_centaur_counter_stomp", "heroes/hero_centaur/counter_stomp", LUA_MODIFIER_MOTION_NONE)

centaur_counter_stomp = class({})

function centaur_counter_stomp:GetIntrinsicModifierName()
	return "modifier_centaur_counter_stomp"
end

modifier_centaur_counter_stomp = class ({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}end,
})

function modifier_centaur_counter_stomp:OnAttackLanded( data )
	local caster = self:GetCaster()
	local target = data.target
	local attacker = data.attacker
		
	if target == caster and target:IsAlive() then	
		local ability = self:GetAbility()
		local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
		local stun_duration = ability:GetSpecialValueFor("stun_duration")
		local radius = ability:GetSpecialValueFor("radius")
		local base_dmg = ability:GetSpecialValueFor("base_dmg")
		local str_dmg = ability:GetSpecialValueFor("str_dmg")/100
		local damage = base_dmg + str_dmg* caster:GetStrength()
			
		if ability:IsCooldownReady() and RollPercentage(trigger_chance) then
			ability:UseResources(false, false, true)
			EmitSoundOn("Hero_Centaur.HoofStomp",caster)
			
			local effect = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
			local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin()) -- Origin
			ParticleManager:SetParticleControl(pfx, 1, Vector(radius, radius, radius)) -- Destination

			local enemies = FindUnitsInRadius(caster:GetTeam(), 
											caster:GetAbsOrigin(), 
											nil, 
											radius, 
											DOTA_UNIT_TARGET_TEAM_ENEMY, 
											DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
											DOTA_UNIT_TARGET_FLAG_NONE, 
											FIND_ANY_ORDER, false)
			
			for i=1,#enemies do
				local enemy = enemies[i]
				DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
				enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
			end
		end
	end
end