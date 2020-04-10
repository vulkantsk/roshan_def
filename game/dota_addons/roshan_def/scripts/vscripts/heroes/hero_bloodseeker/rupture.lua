--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Checks the target's distance from its last position and deals damage accordingly]]
function DistanceCheck(keys)
	local caster = keys.caster
	local target = keys.target
--	print(target)
	local ability = keys.ability
	local movement_damage_pct = ability:GetSpecialValueFor( "movement_damage_pct")
	local damage_hp_pct = ability:GetSpecialValueFor( "movement_damage_hp_pct")/100*target:GetMaxHealth()
	local damage_cap_amount = ability:GetSpecialValueFor( "damage_cap_amount")
	local damage = 0
	
	if target.position == nil then
		target.position = target:GetAbsOrigin()
	end
	local vector_distance = target.position - target:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	if distance <= damage_cap_amount and distance > 0 then
		damage = distance * (movement_damage_pct + damage_hp_pct )/100
	end

	target.position = target:GetAbsOrigin()
	if damage ~= 0 then
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	end
end

function PlaySound(keys)
	local caster = keys.caster
	local target = keys.target

	EmitSoundOn("hero_bloodseeker.rupture",target)
	
end
