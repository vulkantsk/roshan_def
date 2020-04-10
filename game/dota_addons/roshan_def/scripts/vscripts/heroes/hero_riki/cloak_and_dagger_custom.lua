LinkLuaModifier("modifier_riki_cloak_and_dagger_custom", "heroes/hero_riki/cloak_and_dagger_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_cloak_and_dagger_custom_counter", "heroes/hero_riki/cloak_and_dagger_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riki_cloak_and_dagger_custom_bonus", "heroes/hero_riki/cloak_and_dagger_custom", LUA_MODIFIER_MOTION_NONE)

riki_cloak_and_dagger_custom = class({})

function riki_cloak_and_dagger_custom:GetIntrinsicModifierName()
	return "modifier_riki_cloak_and_dagger_custom" 
end


modifier_riki_cloak_and_dagger_custom = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}end,
})

function modifier_riki_cloak_and_dagger_custom:OnAttackLanded(data)
	local attacker = data.attacker
	local target = data.target
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	if attacker == caster and target:GetUnitName() ~= "npc_dota_damage_tester" and not target:IsBuilding() then
	
		local victim_angle = target:GetAnglesAsVector().y
		local origin_difference = target:GetAbsOrigin() - caster:GetAbsOrigin()

		-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
		local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
		
		-- Convert the radian to degrees.
		origin_difference_radian = origin_difference_radian * 180
		local attacker_angle = origin_difference_radian / math.pi
		-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
		attacker_angle = attacker_angle + 180.0
		
		-- Finally, get the angle at which the victim is facing Riki.
		local result_angle = attacker_angle - victim_angle
		result_angle = math.abs(result_angle)
		
		
		-- Check for the backstab angle.
		if (result_angle >= (180 - (ability:GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("backstab_angle") / 2))) or caster:HasModifier("modifier_riki_tricks_of_the_trade_custom_primary") or caster:HasModifier("modifier_riki_tricks_of_the_trade_custom_secondary") or caster:HasModifier("modifier_riki_dance") then 
			self:ReleaseBackstab(target)
		end
	end
end

function modifier_riki_cloak_and_dagger_custom:ReleaseBackstab(target)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local agility_damage_multiplier = ability:GetSpecialValueFor("agility_damage") / 100
	local duration = ability:GetSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Riki.Backstab", target)
	caster:AddNewModifier(caster, ability, "modifier_riki_cloak_and_dagger_custom_bonus", {duration = duration})
	local damage = caster:GetAgility() * agility_damage_multiplier

	local effect = "particles/units/heroes/hero_riki/riki_backstab.vpcf"
	local particle = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, target) 
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
	ParticleManager:ReleaseParticleIndex(particle)

	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(),damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION })	
end

modifier_riki_cloak_and_dagger_custom_bonus = class({
	IsHidden = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}end,
})

function modifier_riki_cloak_and_dagger_custom_bonus:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("agi_gain")
end

function modifier_riki_cloak_and_dagger_custom_bonus:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local duration = ability:GetSpecialValueFor("duration")
	local modifier_name = "modifier_riki_cloak_and_dagger_custom_counter"

		local modifier = caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		modifier:IncrementStackCount()
	
end

function modifier_riki_cloak_and_dagger_custom_bonus:OnDestroy()
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName("modifier_riki_cloak_and_dagger_custom_counter")
	local stack_count = modifier:GetStackCount()
	
	if stack_count <= 1 then
		modifier:Destroy()
	else
		modifier:DecrementStackCount()
	end
end

modifier_riki_cloak_and_dagger_custom_counter = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
})


