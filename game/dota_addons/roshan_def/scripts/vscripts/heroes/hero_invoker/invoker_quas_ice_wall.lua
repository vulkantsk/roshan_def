invoker_quas_ice_wall = class({})
LinkLuaModifier('modifier_invoker_quas_ice_wall_aura', 'heroes/hero_invoker/invoker_quas_ice_wall', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_quas_ice_wall_buff', 'heroes/hero_invoker/invoker_quas_ice_wall', LUA_MODIFIER_MOTION_NONE)
function invoker_quas_ice_wall:OnSpellStart()
    local caster = self:GetCaster()
    local NumWallElements = 15
    local WallElementSpacing = 80
    local WallPlaceDistance = 200
    local duration = 5
	local caster_point = caster:GetAbsOrigin()
	local direction_to_target_point = caster:GetForwardVector()
	target_point = caster_point + (direction_to_target_point * WallPlaceDistance)
	local direction_to_target_point_normal = Vector(-direction_to_target_point.y, direction_to_target_point.x, direction_to_target_point.z)
	local vector_distance_from_center = (direction_to_target_point_normal * (NumWallElements * WallElementSpacing)) / 2
	local one_end_point = target_point - vector_distance_from_center
	
	local ice_wall_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ice_wall_particle_effect, 0, target_point - vector_distance_from_center)
	ParticleManager:SetParticleControl(ice_wall_particle_effect, 1, target_point + vector_distance_from_center)
	
	local ice_wall_particle_effect_b = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_b.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ice_wall_particle_effect_b, 0, target_point - vector_distance_from_center)
	ParticleManager:SetParticleControl(ice_wall_particle_effect_b, 1, target_point + vector_distance_from_center)

	Timers:CreateTimer({
		endTime = duration,
		callback = function()
			ParticleManager:DestroyParticle(ice_wall_particle_effect, false)
			ParticleManager:DestroyParticle(ice_wall_particle_effect_b, false)
		end
    })
    
    for i=1,NumWallElements do 
        local ice_wall_unit = CreateUnitByName("npc_dummy_unit", one_end_point + direction_to_target_point_normal * (WallElementSpacing * i), false, nil, nil, caster:GetTeam())
        ice_wall_unit:AddNewModifier(caster, self, 'modifier_kill', {
            duration = duration,
        })
        ice_wall_unit:AddNewModifier(caster, self, 'modifier_invoker_quas_ice_wall_aura', {
            duration = duration,
            radius = WallElementSpacing / 2,
        })
    end

    caster:StartGesture(ACT_DOTA_CAST_ICE_WALL)

end

modifier_invoker_quas_ice_wall_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,

	IsAura                  = function() return true end,
	GetModifierAura         = function() return "modifier_invoker_quas_ice_wall_buff" end,
	GetAuraSearchTeam       = function() return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType       = function() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
	GetAuraSearchFlags      = function() return DOTA_UNIT_TARGET_FLAG_NONE end,
    GetAuraRadius           = function(self) return self.radius end,

    CheckState              = function(self)
        return {
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        }
    end,
})

function modifier_invoker_quas_ice_wall_aura:OnCreated(data)
    self.radius = data.radius
end 

function modifier_invoker_quas_ice_wall_aura:OnRefresh(data)
    self:OnCreated(data)
end 

modifier_invoker_quas_ice_wall_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,  
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        }
    end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self.movespeed end,  
    GetModifierAttackSpeedBonus_Constant = function(self) return self.attack_speed end,  
})

function modifier_invoker_quas_ice_wall_buff:OnCreated(data)
    self.ability = self:GetAbility()
    self.attack_speed = self.ability:GetSpecialValueFor('attack_speed')
    self.movespeed = self.ability:GetSpecialValueFor('movespeed')

end 

function modifier_invoker_quas_ice_wall_buff:OnRefresh()
    self:OnCreated()
end 