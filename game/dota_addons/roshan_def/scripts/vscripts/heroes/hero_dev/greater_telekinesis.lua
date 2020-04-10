--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Lifts the target in the air]]
function Lift(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	ability.target = target
	ability.target_origin = target:GetAbsOrigin()
	ability.level = ability:GetLevel()
	
	ability:ApplyDataDrivenModifier(caster, target, "modifier_telekinesis_datadriven", {})
	
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Chooses the drop location of the target]]
function Drop(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_land_distance = ability:GetLevelSpecialValueFor("max_land_distance", (ability:GetLevel() -1))
	
	-- The telekinesis ability
	local telekinesis = caster:FindAbilityByName("aghs_greater_telekinesis")
	-- Chosen drop point
	local point = caster:GetAbsOrigin()
	
	
	-- If this the player have already chosen a drop position, destroy the previous particle
	if telekinesis.drop_particle ~= nil then
		ParticleManager:DestroyParticle(telekinesis.drop_particle, true)
	end
	-- Renders the particle on the new drop position
	telekinesis.drop_particle = ParticleManager:CreateParticleForTeam(keys.particle, PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(telekinesis.drop_particle, 0, Vector(point.x, point.y, point.z))
	ParticleManager:SetParticleControl(telekinesis.drop_particle, 1, Vector(point.x, point.y, point.z))
	ParticleManager:SetParticleControl(telekinesis.drop_particle, 2, Vector(point.x, point.y, point.z))
	
	telekinesis.point = point
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Moves the target to the drop position]]
function Fall(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	
	if ability.point ~= nil then
		target.vector_distance = ability.point - target:GetAbsOrigin()
	-- If there is no chosen drop position, it will be the same position the target was lifted from
	else
		ability.point = ability.target_origin
		target.vector_distance = ability.target_origin - target:GetAbsOrigin()
	end
	
	-- Sets the distance the target must fall for every interval
	if target.fall_distance == nil then
		local distance = (target.vector_distance):Length2D()
			
		local fall_duration = ability:GetLevelSpecialValueFor("fall_duration", (ability:GetLevel() -1))
		local intervals = fall_duration/0.01
	
		target.fall_distance = distance/(intervals - 1)
	end
	
	-- Direction and position variables
	local direction = (target.vector_distance):Normalized()
--	local new_position = target:GetAbsOrigin() + (direction * target.fall_distance)
	local new_position = ability.point
	
	-- Moves the target
--	target:SetAbsOrigin(new_position)
	-- Creates awkward animation, but necessary for no clipping
	FindClearSpaceForUnit(target, new_position, true)
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Applies the stun in the AOE]]
function Impact(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	local is_target = false
	

	-- Destroys all previous particles
	--ParticleManager:DestroyParticle(ability.lift_particle, true)
	if ability.drop_particle ~= nil then
		ParticleManager:DestroyParticle(ability.drop_particle, true)
	end

	-- Renders the impact particle on the target
	local particle = ParticleManager:CreateParticleForTeam(keys.particle, PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z))
	ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z))
	
	-- Swaps back telekinesis and telekinesis land
	--caster:SwapAbilities("aghs_greater_telekinesis_land", "aghs_greater_telekinesis", false, true)

	-- Units to be caught in the stun
	local units = FindUnitsInRadius(caster:GetTeamNumber(), ability.point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)

	-- Applies the stun to all units in the AOE except the target
	for i,unit in ipairs(units) do
		unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end
	EmitSoundOn(keys.sound, target)
	
	target.vector_distance = nil
	target.fall_distance = nil
	ability.point = nil
end