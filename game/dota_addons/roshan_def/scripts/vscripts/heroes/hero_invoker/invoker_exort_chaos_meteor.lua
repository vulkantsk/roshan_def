invoker_exort_chaos_meteor = class({})

function invoker_exort_chaos_meteor:OnSpellStart()
    local caster = self:GetCaster()
    local caster_point = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
    local target_point_temp = Vector(target_point.x, target_point.y, 0)
    local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
    local speed = self:GetSpecialValueFor('fly_speed')
    local speed_travel = self:GetSpecialValueFor('speed_travel')
    local velocity_per_second = point_difference_normalized *  speed
    local VisionDistance = self:GetSpecialValueFor('VisionDistance')
    local LandTime = 1.3
    local travel_distance = self:GetSpecialValueFor('travel_distance')
    local fireDuration = self:GetSpecialValueFor('duration')
    local base_damage = self:GetSpecialValueFor('base_damage')
    local int_damage = self:GetSpecialValueFor('int_damage') * caster:GetIntellect()/100
    local meteorDMG =  base_damage + int_damage
    local dps_thinker = self:GetSpecialValueFor('dps_thinker')
    local dps_interval = self:GetSpecialValueFor('dps_interval')

	caster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
    EmitSoundOn("Hero_Invoker.ChaosMeteor.Loop",caster)
    caster:EmitSound("invoker_invo_ability_chaosmeteor_0" .. RandomInt(1,7))
    caster:StartGesture(ACT_DOTA_CAST_CHAOS_METEOR)

	local meteor_fly_original_point = (target_point - (velocity_per_second * LandTime)) + Vector (0, 0, 1000)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, target_point)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(LandTime, 0, 0))
    ParticleManager:ReleaseParticleIndex(chaos_meteor_fly_particle_effect)

    Timers:CreateTimer(LandTime,function()		
			local chaos_meteor_dummy_unit = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())			
			StopSoundOn("Hero_Invoker.ChaosMeteor.Loop",caster)
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
            EmitSoundOn("Hero_Invoker.ChaosMeteor.Loop",chaos_meteor_dummy_unit)
            local abilityDummy = chaos_meteor_dummy_unit:AddAbility('ability_chaos_meteor_dummy_unit')
            abilityDummy:SetLevel(1)
			
			chaos_meteor_dummy_unit:SetDayTimeVisionRange(VisionDistance)
			chaos_meteor_dummy_unit:SetNightTimeVisionRange(VisionDistance)
			            
            local chaos_meteor_duration = travel_distance / speed_travel
            local chaos_meteor_velocity_per_frame = velocity_per_second * 0.03
                    
            EmitSoundOn("Hero_Batrider.Firefly.loop", chaos_meteor_dummy_unit)

            abilityDummy.firefly = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly.vpcf", PATTACH_POINT, chaos_meteor_dummy_unit)
            ParticleManager:SetParticleControlEnt(abilityDummy.firefly, 0, chaos_meteor_dummy_unit, PATTACH_ABSORIGIN_FOLLOW, nil, chaos_meteor_dummy_unit:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(abilityDummy.firefly, 3, chaos_meteor_dummy_unit, PATTACH_ABSORIGIN_FOLLOW, nil, chaos_meteor_dummy_unit:GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(abilityDummy.firefly, 11, Vector(1, 0, 0))

            -- data for projectiles
            abilityDummy.particleDuration = chaos_meteor_duration + fireDuration
            abilityDummy.radius = 100
            abilityDummy.dmg = meteorDMG
            abilityDummy.dps_thinker = dps_thinker
            abilityDummy.dps_interval = dps_interval
            abilityDummy.ability = self
			local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile({
				EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
				Ability = abilityDummy,
				vSpawnOrigin = target_point,
				fDistance = travel_distance,
				fStartRadius = abilityDummy.radius,
				fEndRadius = abilityDummy.radius,
				Source = chaos_meteor_dummy_unit,
				bHasFrontalCone = false,
				iMoveSpeed = speed,
				bReplaceExisting = false,
				bProvidesVision = true,
				iVisionTeamNumber = caster:GetTeam(),
				iVisionRadius = VisionDistance,
				bDrawsOnMinimap = false,
				bVisibleToEnemies = true, 
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO +  DOTA_UNIT_TARGET_BASIC,
                fExpireTime = GameRules:GetGameTime() + chaos_meteor_duration,
                vVelocity = point_difference_normalized *  speed_travel
            })

            Timers:CreateTimer(abilityDummy.particleDuration,function()
                if abilityDummy.firefly then 
                    ParticleManager:DestroyParticle(abilityDummy.firefly, true)
                    ParticleManager:ReleaseParticleIndex(abilityDummy.firefly)
                    StopSoundOn("Hero_Invoker.ChaosMeteor.Loop", chaos_meteor_dummy_unit)
                    StopSoundOn("Hero_Batrider.Firefly.loop", chaos_meteor_dummy_unit)
                    chaos_meteor_dummy_unit:ForceKill(false)


                    abilityDummy.firefly = nil
                end
            end )
		end)
end 