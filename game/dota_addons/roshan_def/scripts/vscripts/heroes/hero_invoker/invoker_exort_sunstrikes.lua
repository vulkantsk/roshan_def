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
    local interval = self:GetSpecialValueFor('interval')
    local radius_sunstrike  = self:GetSpecialValueFor('radius_sunstrike')
    local sunstrike_delay = self:GetSpecialValueFor('sunstrike_delay')
    self:GetCaster():EmitSound("invoker_invo_ability_sunstrike_0" .. RandomInt(1,5))
    caster:StartGesture(ACT_DOTA_CAST_SUN_STRIKE)

    for i=1, count do 
        Timers:CreateTimer(i*interval, function()
            local vSunstrikePoint = vPoint + RandomVector(RandomFloat(-radius,radius))
            self:CreateVisibilityNode(vSunstrikePoint, radius_sunstrike, sunstrike_delay + 0.2)
            local dummy = CreateUnitByName("dummy_unit_vulnerable", vSunstrikePoint, false, nil, nil, caster:GetTeam())
            dummy:EmitSound("Hero_Invoker.SunStrike.Charge")
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
                dummy:EmitSound("Hero_Invoker.SunStrike.Ignite")
                dummy:RemoveSelf()
                
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
        end)
    end 


end