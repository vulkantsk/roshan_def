LinkLuaModifier("modifier_hoodwink_acorn_shoot_custom", "heroes/hero_hoodwink/acorn_shoot", LUA_MODIFIER_MOTION_NONE)

hoodwink_acorn_shoot_custom = class({})

function hoodwink_acorn_shoot_custom:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function hoodwink_acorn_shoot_custom:OnSpellStart()
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local vDirection = self:GetCursorPosition() - caster:GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()
   
    local index = RandomInt(1, 15)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("hoodwink_hoodwink_acorn_en_"..index)
    caster:EmitSound("Hero_Hoodwink.AcornShot.Cast")

   local thinker = CreateModifierThinker(caster, self, "modifier_phased", nil, point, caster:GetTeam(), false)
   thinker.target = true
     
    ProjectileManager:CreateTrackingProjectile({
        Target = thinker,
        Source = caster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf",
        bDodgeable = false,
        bProvidesVision = true,
        iMoveSpeed = 1000,
        iVisionRadius = 200,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {
            main_target = true
        }
    })  
end 

function hoodwink_acorn_shoot_custom:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if ExtraData.main_target then       
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("reveal_duration")
        local radius = self:GetSpecialValueFor("radius")
        AddFOWViewer(caster:GetTeam(), vLocation, radius, duration, false)
        
        local units = FindUnitsInRadius(caster:GetTeamNumber(), 
                                vLocation,
                                nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, 
                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                                FIND_ANY_ORDER, 
                                false) 

        for _, unit in pairs (units) do      
            ProjectileManager:CreateTrackingProjectile({
                Target = unit,
                Source = hTarget,
                Ability = self,
                EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf",
                bDodgeable = false,
                bProvidesVision = true,
                iMoveSpeed = 1000,
            })             
        end
        hTarget:EmitSound("Hero_Hoodwink.AcornShot.Slow")
        hTarget:ForceKill(false)
    else
        local caster = self:GetCaster()
        hTarget:EmitSound("Hero_Hoodwink.AcornShot.Bounce")
        caster:PerformAttack(hTarget, true, true, true, true, false, false, true)
    end
end

