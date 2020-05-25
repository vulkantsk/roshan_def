--Путь к этому файлу
local path_to_file = 'heroes/hero_invoker/combo_vombo' -- Если файл в корне
LinkLuaModifier('modifier_invoker_combo_vombo_move',path_to_file,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier('modifier_invoker_combo_vombo_meteor',path_to_file,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_combo_vombo_target',path_to_file,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_combo_vombo_unit_burn',path_to_file,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_combo_vombo_disarm',path_to_file,LUA_MODIFIER_MOTION_NONE)

if not invoker_combo_vombo then
	invoker_combo_vombo = class({})
end

function invoker_combo_vombo:OnSpellStart()
	local caster = self:GetCaster()
	local caster_origin = caster:GetAbsOrigin()
	self.cachedorigin = caster_origin
	caster:EmitSound('Hero_Invoker.Tornado.Cast')
	local castrange = self:GetCastRange(caster_origin,nil)
	local range = self:GetSpecialValueFor('tornado_range')
	local speed = self:GetSpecialValueFor('tornado_speed') /30
	local vision = self:GetSpecialValueFor('tornado_vision')
	local point = self:GetCursorPosition()
	local tornado_dummy_unit = CreateUnitByName("npc_dummy_unit", caster_origin, false, caster, caster, caster:GetTeam())
	local tornado_mod = tornado_dummy_unit:AddNewModifier(caster,self,'modifier_invoker_combo_vombo_move',{speed = speed,tornado_range=range,range = castrange})
	local tornado_part = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_tornado_funnel.vpcf', PATTACH_ABSORIGIN_FOLLOW,tornado_dummy_unit)
    ParticleManager:SetParticleControl(tornado_part,3,tornado_dummy_unit:GetAbsOrigin())
	tornado_dummy_unit:EmitSound("Hero_Invoker.Tornado")
	tornado_dummy_unit:SetDayTimeVisionRange(vision)
	tornado_dummy_unit:SetNightTimeVisionRange(vision)
	tornado_mod.effect = tornado_part
end
if not modifier_invoker_combo_vombo_move then
	modifier_invoker_combo_vombo_move=class({})
end
function modifier_invoker_combo_vombo_move:IsHidden()
	return true
end
if IsServer() then
function modifier_invoker_combo_vombo_move:UpdateHorizontalMotion( me, dt )
    if self.traveled < self.distance then
      	local vectormove = self.direction * self.speed
      	self.par:SetAbsOrigin(self.par:GetAbsOrigin() + vectormove)
      	self.traveled = self.traveled + (vectormove):Length2D()
      	ParticleManager:SetParticleControl(self.effect,3,self.par:GetAbsOrigin())
    else
      	self.par:InterruptMotionControllers(true)
		self.par:StopSound("Hero_Invoker.Tornado")
      	UTIL_Remove(self.par)
    end
end
function modifier_invoker_combo_vombo_move:OnHorizontalMotionInterrupted()
    self.par:RemoveHorizontalMotionController(self)
end
function modifier_invoker_combo_vombo_move:OnCreated(t)
    self.caster = self:GetCaster()
	local point = self:GetAbility():GetCursorPosition()
	point.z = 0
	local caster_point = self.caster:GetAbsOrigin()
	caster_point.z = 0
	local point_difference_normalized = (point - caster_point):Normalized()
	if point_difference_normalized == Vector(0,0,0) then
		point_difference_normalized = self.caster:GetForwardVector()
	end
    self.par = self:GetParent()
    self.direction = point_difference_normalized
    self.distance = t.range
    self.speed = t.speed
    self.traveled = 0
    self.attacked = {}
    self.tornado_range = t.tornado_range
    self:StartIntervalThink(0.1)
    self:ApplyHorizontalMotionController()
end
function modifier_invoker_combo_vombo_move:OnIntervalThink()
  local units = FindUnitsInRadius(self.caster:GetTeamNumber(),self.par:GetAbsOrigin(),nil,self.tornado_range,self:GetAbility():GetAbilityTargetTeam(),self:GetAbility():GetAbilityTargetType(),self:GetAbility():GetAbilityTargetFlags(),FIND_ANY_ORDER,false)
  if units then
    for _,v in ipairs(units) do
    	if not self.attacked[v] then
			v:EmitSound("Hero_Invoker.Tornado.Target")
	        self.attacked[v] = true
	        v.tornado_forward_vector = v:GetForwardVector()
	        v:AddNewModifier(self.caster,self:GetAbility(),'modifier_invoker_combo_vombo_target',{duration=self:GetAbility():GetSpecialValueFor('tornado_lift_duration')})
	    end
    end
  end
  return 0.1
end
end
function modifier_invoker_combo_vombo_move:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
end

function modifier_invoker_combo_vombo_move:CheckState()
    return {
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true
  }
end
function modifier_invoker_combo_vombo_move:GetAbsoluteNoDamageMagical()
    return 1
end
function modifier_invoker_combo_vombo_move:GetAbsoluteNoDamagePhysical()
    return 1
end
function modifier_invoker_combo_vombo_move:GetAbsoluteNoDamagePure()
    return 1
end
function modifier_invoker_combo_vombo_move:GetMinHealth()
    return 1
end
if not modifier_invoker_combo_vombo_target then
	modifier_invoker_combo_vombo_target = class({})
end
function modifier_invoker_combo_vombo_target:IsHidden()
	return false
end
function modifier_invoker_combo_vombo_target:GetTexture()
	return 'invoker_tornado'
end
function modifier_invoker_combo_vombo_target:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_invoker_combo_vombo_target:GetEffectName()
	return 'particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf'
end
function modifier_invoker_combo_vombo_target:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end
function modifier_invoker_combo_vombo_target:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end
function modifier_invoker_combo_vombo_target:CheckState()
    return {
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_STUNNED] = true,
    [MODIFIER_STATE_ROOTED] = true,
    [MODIFIER_STATE_DISARMED] = true,
    [MODIFIER_STATE_FLYING] = true
  }
end
if IsServer() then
function modifier_invoker_combo_vombo_target:OnCreated(t)
	self.par = self:GetParent()
	self.caster = self:GetCaster()
	self.duration = self:GetDuration()
	self.position = self.par:GetAbsOrigin()
	self.ground_position = GetGroundPosition(self.position, self.par)
	self.cyclone_initial_height = self:GetAbility():GetSpecialValueFor('tornado_initial_height') + self.ground_position.z
	self.cyclone_min_height = self:GetAbility():GetSpecialValueFor('tornado_min_height') + self.ground_position.z
	self.cyclone_max_height = self:GetAbility():GetSpecialValueFor('tornado_max_height') + self.ground_position.z
	self.tornado_lift_duration = self:GetAbility():GetSpecialValueFor('tornado_lift_duration')
	self.time_to_reach_initial_height = self.duration / 10
	self.initial_ascent_height_per_frame = ((self.cyclone_initial_height - self.position.z) / self.time_to_reach_initial_height) /30
	self.up_down_cycle_height_per_frame = self.initial_ascent_height_per_frame / 3
	if self.up_down_cycle_height_per_frame > 7.5 then
		self.up_down_cycle_height_per_frame = 7.5
	end
	self.final_descent_height_per_frame = nil
	self.time_to_stop_fly = self.duration - self.time_to_reach_initial_height
	self.going_up = true
	self.tornado_start = GameRules:GetGameTime()

    local sunstrike_delay = self:GetAbility():GetSpecialValueFor('sunstrike_delay')
    local sunstrike_area = self:GetAbility():GetSpecialValueFor('sunstrike_area')
    if self.tornado_lift_duration < sunstrike_delay then
    	sunstrike_delay = self.tornado_lift_duration
    end
    local meteor_delay = self:GetAbility():GetSpecialValueFor('meteor_land_time')
    if self.tornado_lift_duration < meteor_delay then
    	meteor_delay = self.tornado_lift_duration
    end
    local pos = self.par:GetAbsOrigin()
    local castpos = self.caster:GetAbsOrigin()
    local caster_point_temp = Vector(castpos.x, castpos.y, 0)
	local target_point_temp = Vector(pos.x, pos.y, 0)
 	local ab = self:GetAbility()
 	local par = self:GetParent()
 	local cas = self:GetCaster()
	local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
	local velocity_per_second = point_difference_normalized * ab:GetSpecialValueFor('meteor_travel_speed')
	local chaos_meteor_velocity_per_frame = velocity_per_second /30
	Timers(self.tornado_lift_duration-meteor_delay,function()
		cas:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
		cas:EmitSound("Hero_Invoker.ChaosMeteor.Loop")
		local vis = ab:GetSpecialValueFor('meteor_vision_distance')
		local dis = ab:GetSpecialValueFor('meteor_travel_distance')
		local ms = ab:GetSpecialValueFor('meteor_travel_speed')
		local dur = dis / ms
		local endvis = ab:GetSpecialValueFor('meteor_end_vision_duration')
		local burndur = ab:GetSpecialValueFor('meteor_burn_duration')
		local meteor_fly_original_point = (pos - (velocity_per_second * meteor_delay)) + Vector (0, 0, 1000)
		local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, cas)
		ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
		ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, pos)
		ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(meteor_delay, 0, 0))
		Timers(meteor_delay,function()
			local chaos_meteor_dummy_unit = CreateUnitByName("npc_dummy_unit", pos, false, cas, cas, cas:GetTeam())
			cas:StopSound("Hero_Invoker.ChaosMeteor.Loop")
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Loop")
			chaos_meteor_dummy_unit:SetDayTimeVisionRange(vis)
			chaos_meteor_dummy_unit:SetNightTimeVisionRange(vis)
			local meteor_mod = chaos_meteor_dummy_unit:AddNewModifier(cas,ab,'modifier_invoker_combo_vombo_meteor',{})
			local projectile_information =  
			{
				EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
				Ability = ab,
				vSpawnOrigin = pos,
				fDistance = dis,
				fStartRadius = 0,
				fEndRadius = 0,
				Source = cas,
				bHasFrontalCone = false,
				iMoveSpeed = ms,
				bReplaceExisting = false,
				bProvidesVision = true,
				iVisionTeamNumber = cas:GetTeam(),
				iVisionRadius = vis,
				bDrawsOnMinimap = false,
				bVisibleToEnemies = true, 
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_NONE,
				fExpireTime = GameRules:GetGameTime() + dur + endvis,
				vVelocity = velocity_per_second
			}
			local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)
			local endTime = GameRules:GetGameTime() + dur
			Timers(function()
				chaos_meteor_dummy_unit:SetAbsOrigin(chaos_meteor_dummy_unit:GetAbsOrigin() + chaos_meteor_velocity_per_frame)
				if GameRules:GetGameTime() > endTime then
					chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Loop")
					chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Destroy")
					meteor_mod:StartIntervalThink(-1)
					Timers(endvis,function()
							chaos_meteor_dummy_unit:SetDayTimeVisionRange(0)
							chaos_meteor_dummy_unit:SetNightTimeVisionRange(0)
							chaos_meteor_dummy_unit:RemoveSelf()
						end)
					return 
				else 
					return .03
				end
			end)
		end)
	end)
    Timers(self.tornado_lift_duration-sunstrike_delay,function()
    	local particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", PATTACH_ABSORIGIN, par, cas:GetTeamNumber())
		ParticleManager:SetParticleControl(particle, 0, pos) 
		ParticleManager:SetParticleControl(particle, 1, Vector(sunstrike_area,0,0))
		par:EmitSound("Hero_Invoker.SunStrike.Charge")
		ab:CreateVisibilityNode(pos,ab:GetSpecialValueFor('sunstrike_vision_distance'),ab:GetSpecialValueFor('sunstrike_vision_duration'))
		Timers(sunstrike_delay,function()
			ParticleManager:DestroyParticle(particle,false)
			par:EmitSound("Hero_Invoker.SunStrike.Ignite")
	    	particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_ABSORIGIN, par)
			ParticleManager:SetParticleControl(particle, 1, Vector(sunstrike_area,0,0))
			ParticleManager:ReleaseParticleIndex(particle)
		  	local units = FindUnitsInRadius(cas:GetTeamNumber(),pos,nil,sunstrike_area,ab:GetAbilityTargetTeam(),ab:GetAbilityTargetType(),ab:GetAbilityTargetFlags(),FIND_CLOSEST,false)
		    for _,v in ipairs(units) do
				ApplyDamage({victim = v, attacker = cas, damage = ab:GetSpecialValueFor('sunstrike_damage')/ #units, damage_type = ab:GetSpecialValueFor('sunstrike_damage_type')})
		    end
		end)
    end)
	local velocity_per_second_df = point_difference_normalized * ab:GetSpecialValueFor('df_travel_speed')
	local df_original_point = (pos - velocity_per_second_df*0.5) + Vector (0, 0, 1000)
    Timers(self.tornado_lift_duration,function()
    	local projectile_table =
		{
			EffectName = 'particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf',
			Ability = ab,
			vSpawnOrigin = df_original_point,
			vVelocity = velocity_per_second_df,
			fDistance = ab:GetSpecialValueFor('df_travel_distance'),
			fStartRadius = ab:GetSpecialValueFor('df_radius_start'),
			fEndRadius = ab:GetSpecialValueFor('df_radius_end'),
			Source = cas,
			bHasFrontalCone = true,
			bReplaceExisting = false,
			iUnitTargetTeam = ab:GetAbilityTargetTeam(),
			iUnitTargetFlags = ab:GetAbilityTargetFlags(),
			iUnitTargetType = ab:GetAbilityTargetType()
		}
		ProjectileManager:CreateLinearProjectile( projectile_table )
    end)

    self:StartIntervalThink(0.03)
end
function modifier_invoker_combo_vombo_target:OnIntervalThink()
	local time_in_air = GameRules:GetGameTime() - self.tornado_start
    if self.position.z < self.cyclone_initial_height and time_in_air <= self.time_to_reach_initial_height then
		self.position.z = self.position.z + self.initial_ascent_height_per_frame
		self.par:SetOrigin(self.position)
	elseif time_in_air > self.time_to_stop_fly and time_in_air <= self.duration then
		if self.final_descent_height_per_frame == nil then
			self.descent_initial_height_above_ground = self.position.z - self.ground_position.z
			self.final_descent_height_per_frame = (self.descent_initial_height_above_ground / self.time_to_reach_initial_height) /30
		end
		self.position.z = self.position.z - self.final_descent_height_per_frame
		self.par:SetOrigin(self.position)
	elseif time_in_air <= self.duration then
		if self.position.z < self.cyclone_max_height and self.going_up then
			self.position.z = self.position.z + self.up_down_cycle_height_per_frame
			self.par:SetOrigin(self.position)
		elseif self.position.z >= self.cyclone_min_height then
			self.going_up = false
			self.position.z = self.position.z - self.up_down_cycle_height_per_frame
			self.par:SetOrigin(self.position)
		else
			self.going_up = true
		end
	end
	if self.par.tornado_degrees_to_spin == nil and self.tornado_lift_duration ~= nil then
		local ideal_degrees_per_second = 666.666
		local ideal_full_spins = (ideal_degrees_per_second / 360) * self.tornado_lift_duration
		ideal_full_spins = math.floor(ideal_full_spins + .5)
		local degrees_per_second_ending_in_same_forward_vector = (360 * ideal_full_spins) / self.tornado_lift_duration
		self.par.tornado_degrees_to_spin = degrees_per_second_ending_in_same_forward_vector * .03
	end
	self.par:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0, self.par.tornado_degrees_to_spin, 0), self.par:GetForwardVector()))
end
function modifier_invoker_combo_vombo_target:OnDestroy()
	self.par:StopSound("Hero_Invoker.Tornado.Target")
	self.par:EmitSound("Hero_Invoker.Tornado.LandDamage")
	if self.par.tornado_forward_vector ~= nil then
		self.par:SetForwardVector(self.par.tornado_forward_vector)
	end
	ApplyDamage({victim = self.par, attacker = self.caster, damage = self:GetAbility():GetSpecialValueFor('tornado_damage'), damage_type = self:GetAbility():GetSpecialValueFor('tornado_damage_type')})
	self.par.tornado_degrees_to_spin = nil
end
end

if not modifier_invoker_combo_vombo_meteor then
	modifier_invoker_combo_vombo_meteor=class({})
end
function modifier_invoker_combo_vombo_meteor:IsHidden()
	return true
end
if IsServer() then
function modifier_invoker_combo_vombo_meteor:OnCreated(t)
    self.caster = self:GetCaster()
    self.par = self:GetParent()
    self.ab = self:GetAbility()
    self.interval = self.ab:GetSpecialValueFor('meteor_damage_interval')
    self.dur = self.ab:GetSpecialValueFor('meteor_burn_duration')
    self.maindmg = self.ab:GetSpecialValueFor('meteor_main_damage')
    self.dmgtype = self.ab:GetSpecialValueFor('meteor_damage_type')
    self.range = self.ab:GetSpecialValueFor('meteor_range')
    self:StartIntervalThink(self.interval)
end
function modifier_invoker_combo_vombo_meteor:OnIntervalThink()
  	local nearby_enemy_units = FindUnitsInRadius(self.caster:GetTeamNumber(), self.par:GetAbsOrigin(), nil, self.range,self.ab:GetAbilityTargetTeam(),self.ab:GetAbilityTargetType(),self.ab:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,v in ipairs(nearby_enemy_units) do
		v:EmitSound("Hero_Invoker.ChaosMeteor.Damage")
		ApplyDamage({victim = v, attacker = self.caster, damage = self.maindmg, damage_type = self.dmgtype})
		v:AddNewModifier(self.caster,self.ab,'modifier_invoker_combo_vombo_unit_burn',{duration=self.dur})
	end
  	return self.interval
end
end
function modifier_invoker_combo_vombo_meteor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
end

function modifier_invoker_combo_vombo_meteor:CheckState()
    return {
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true
  }
end
function modifier_invoker_combo_vombo_meteor:GetAbsoluteNoDamageMagical()
    return 1
end
function modifier_invoker_combo_vombo_meteor:GetAbsoluteNoDamagePhysical()
    return 1
end
function modifier_invoker_combo_vombo_meteor:GetAbsoluteNoDamagePure()
    return 1
end
function modifier_invoker_combo_vombo_meteor:GetMinHealth()
    return 1
end
if not modifier_invoker_combo_vombo_unit_burn then
	modifier_invoker_combo_vombo_unit_burn=class({})
end
function modifier_invoker_combo_vombo_unit_burn:IsHidden()
	return false
end
function modifier_invoker_combo_vombo_unit_burn:GetTexture()
	return 'invoker_chaos_meteor'
end
function modifier_invoker_combo_vombo_unit_burn:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
if IsServer() then
function modifier_invoker_combo_vombo_unit_burn:OnCreated(t)
    self.caster = self:GetCaster()
    self.par = self:GetParent()
    self.ab = self:GetAbility()
    self.interval = self.ab:GetSpecialValueFor('meteor_burn_dps_inverval')
    self.dmg = self.ab:GetSpecialValueFor('meteor_burn_dps')
    self.dmgtype = self.ab:GetSpecialValueFor('meteor_damage_type')
    self:StartIntervalThink(self.interval)
end
function modifier_invoker_combo_vombo_unit_burn:OnIntervalThink()
	ApplyDamage({victim = self.par, attacker = self.caster, damage = self.dmg, damage_type = self.dmgtype})
  	return self.interval
end
function invoker_combo_vombo:OnProjectileHit(hTarget,Location)
	if hTarget ~= nil then
		local dur = self:GetSpecialValueFor('df_knockback_duration')
		hTarget:ApplyDFKnockback(self:GetCaster(),self.cachedorigin,false,dur,self:GetSpecialValueFor('df_knockback_distance_per_sec')*dur,0,self)
		local mod = hTarget:AddNewModifier(self:GetCaster(),self,'modifier_invoker_combo_vombo_disarm',{duration=self:GetSpecialValueFor('df_disarm_duration')})
		ApplyDamage({victim = hTarget, attacker = self:GetCaster(), damage = self:GetSpecialValueFor('df_damage'), damage_type = self:GetSpecialValueFor('df_damage_type')})
		Timers(dur,function()
			mod:StartIntervalThink(-1)
		end)
	end
end
function CDOTA_BaseNPC:ApplyDFKnockback(caster,center,stun,duration,distance,height,ability)
    local center = center or caster:GetAbsOrigin()
    local knockbackModifierTable =
    {
        should_stun = stun or 0,
        knockback_duration = duration or 0,
        duration = duration or 0,
        knockback_distance = distance or 0,
        knockback_height = height or 0,
        center_x = center.x,
        center_y = center.y,
        center_z = center.z,
    }
    self:AddNewModifier(caster, ability, "modifier_knockback", knockbackModifierTable)
end
end
if not modifier_invoker_combo_vombo_disarm then
	modifier_invoker_combo_vombo_disarm = class({})
end
function modifier_invoker_combo_vombo_disarm:IsHidden()
	return false
end
function modifier_invoker_combo_vombo_disarm:GetTexture()
	return 'invoker_deafening_blast'
end
function modifier_invoker_combo_vombo_disarm:GetEffectName()
	return 'particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf'
end
function modifier_invoker_combo_vombo_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_invoker_combo_vombo_disarm:GetStatusEffectName()
	return 'particles/status_fx/status_effect_frost.vpcf'
end
if IsServer() then
function modifier_invoker_combo_vombo_disarm:OnCreated(table)
	self.par = self:GetParent()
	self.radius = self:GetAbility():GetSpecialValueFor('df_tree_radius')
	self:OnIntervalThink(0.03)
end
function modifier_invoker_combo_vombo_disarm:OnIntervalThink()
	GridNav:DestroyTreesAroundPoint(self.par:GetAbsOrigin(),self.radius,true)
	return 0.03
end
end
function modifier_invoker_combo_vombo_disarm:CheckState()
    return {
    [MODIFIER_STATE_DISARMED] = true
  }
end