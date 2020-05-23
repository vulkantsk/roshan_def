LinkLuaModifier('modifier_invoker_quas_ice_wall_aura', 'heroes/hero_invoker/invoker_quas_ice_wall', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_invoker_quas_ice_wall_debuff', 'heroes/hero_invoker/invoker_quas_ice_wall', LUA_MODIFIER_MOTION_NONE)

invoker_quas_ice_wall = class({})

function invoker_quas_ice_wall:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function invoker_quas_ice_wall:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    
    local thinker = CreateModifierThinker(caster, self, "modifier_invoker_quas_ice_wall_aura", {duration = duration, radius = radius}, point, caster:GetTeamNumber(), false)
    local modifier = thinker:FindModifierByName("modifier_invoker_quas_ice_wall_aura")
    
    local effect = "particles/econ/items/ancient_apparition/ancient_apparation_ti8/ancient_ice_vortex_ti8.vpcf"
    local pfx = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, point)
    ParticleManager:SetParticleControl(pfx, 5, Vector(radius,radius,radius))
    modifier:AddParticle(pfx, true, false, 3, true, false)

    caster:StartGesture(ACT_DOTA_CAST_ICE_WALL)
    self:GetCaster():EmitSound("Hero_Invoker.IceWall.Cast")
    self:GetCaster():EmitSound("invoker_invo_ability_icewall_0" .. RandomInt(1,5))
end
--[[
function invoker_quas_ice_wall:OnSpellStart()
    local caster = self:GetCaster()
    local NumWallElements = 15
    local WallElementSpacing = 80
    local WallPlaceDistance = self:GetCastRange(self:GetCursorPosition(),nil)
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
    self:GetCaster():EmitSound("Hero_Invoker.IceWall.Cast")
    self:GetCaster():EmitSound("invoker_invo_ability_icewall_0" .. RandomInt(1,5))

end
]]
modifier_invoker_quas_ice_wall_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
	IsAura                  = function() return true end,
	GetModifierAura         = function() return "modifier_invoker_quas_ice_wall_debuff" end,
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

modifier_invoker_quas_ice_wall_debuff = class({
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

function modifier_invoker_quas_ice_wall_debuff:OnCreated(data)
--    self:GetParent():EmitSound("Hero_Invoker.IceWall.Slow")
    self.ability = self:GetAbility()
    self.attack_speed = self.ability:GetSpecialValueFor('attack_speed')*(-1)
    self.movespeed = self.ability:GetSpecialValueFor('movespeed')*(-1)

end 

function modifier_invoker_quas_ice_wall_debuff:OnRefresh()
    self:OnCreated()
end 