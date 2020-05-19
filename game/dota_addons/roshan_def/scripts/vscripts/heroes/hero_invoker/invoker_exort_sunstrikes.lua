invoker_exort_sunstrikes = class({})

function invoker_exort_sunstrikes:GetAOERadius()
    return self:GetSpecialValueFor('radius')
end 

function invoker_exort_sunstrikes:OnSpellStart()

    local vPoint = self:GetCursorPosition()
    local caster = self:GetCaster()
    local radius = self:GetAOERadius()
    local damage = self:GetSpecialValueFor('damage')
    local count = self:GetSpecialValueFor('count')
    local radius_sunstrike  = self:GetSpecialValueFor('radius_sunstrike')
    local sunstrike_delay = self:GetSpecialValueFor('sunstrike_delay')

    caster:StartGesture(ACT_DOTA_CAST_SUN_STRIKE)

    self:CreateVisibilityNode(vPoint, radius, sunstrike_delay + 0.2)
    for i=1, count do 
        local vSunstrikePoint = vPoint + RandomVector(RandomFloat(-radius,radius))
        local nfx = ParticleManager:CreateParticleForTeam('particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf', PATTACH_ABSORIGIN, caster, caster:GetTeam())
        ParticleManager:SetParticleControl(nfx, 0, vSunstrikePoint) 
        ParticleManager:SetParticleControl(nfx, 1, Vector(radius_sunstrike,0,0))
        Timers:CreateTimer(sunstrike_delay,function()
            ParticleManager:DestroyParticle(nfx,true)
            ParticleManager:ReleaseParticleIndex(nfx)

            local nfx = ParticleManager:CreateParticleForTeam('particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf', PATTACH_ABSORIGIN, caster, caster:GetTeam())
            ParticleManager:SetParticleControl(nfx, 0, vSunstrikePoint) 
            ParticleManager:SetParticleControl(nfx, 1, Vector(radius_sunstrike,0,0))
            ParticleManager:ReleaseParticleIndex(nfx)

            local units = FindUnitsInRadius(caster:GetTeamNumber(), 
            vSunstrikePoint, 
            nil, 
            radius_sunstrike, 
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_CLOSEST, 
            false)

            for k,v in pairs(units) do 
                ApplyDamage(({
                    victim = v,
                    attacker = caster,
                    damage = damage,
                    ability = self,
                    damage_type = self:GetAbilityDamageType(),
                }))
            end 

        end )
    end 


end