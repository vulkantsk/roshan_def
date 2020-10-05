LinkLuaModifier("modifier_jakiro_ice_ball_freeze", "heroes/hero_jakiro/ice_ball", 0)
LinkLuaModifier("modifier_jakiro_ice_ball_damage_reduction", "heroes/hero_jakiro/ice_ball", 0)

jakiro_ice_ball = class({})

function jakiro_ice_ball:GetAOERadius()
    return self:GetSpecialValueFor("damage_radius")
end

function jakiro_ice_ball:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
    local vDirection = (point - caster:GetAbsOrigin()):Normalized()

	ProjectileManager:CreateLinearProjectile({
		EffectName = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_initial_ti5.vpcf",
		Abiltity = self,
		vSpawnOrigin = caster:GetAbsOrigin(),--caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fStartRadius = 0,
		fEndRadius = 0,
		vVelocity = vDirection * self:GetSpecialValueFor("ice_ball_speed"),
		fDistance = (caster:GetAbsOrigin() - self:GetCursorPosition()):Length2D(),
		Source = caster,
		iUnitTargetTeam = self:GetAbilityTargetTeam(),
		iUnitTargetType = self:GetAbilityTargetType(),
		iUnitTargetFlags = self:GetAbilityTargetFlags(),
		bProvidesVision = true,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iVisionRadius = self:GetSpecialValueFor("vision_radius")
    })
end


function jakiro_ice_ball:OnProjectileHit(target, location)
    local caster = self:GetCaster()
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(pfx, 0, location)
    ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("damage_radius"), 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx)

    if not target then
        local enemies_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("damage_radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
        for _, enemy in pairs(enemies_in_radius) do
            local damage = self:GetSpecialValueFor("damage")

            if enemy:HasModifier("modifier_jakiro_dual_breath_new_ice") then --! Замедление с 1 скилла Джакиро
                damage = damage + (damage / 100 * self:GetSpecialValueFor("dual_breath_damage_amp_pct"))
                enemy:AddNewModifier(caster, self, "modifier_ice_ball_freeze", {duration = self:GetSpecialValueFor("freeze_duration")})
                enemy:AddNewModifier(caster, self, "modifier_jakiro_ice_ball_damage_reduction", {duration = self:GetSpecialValueFor("damage_reduction_duration")})
            end
            if enemy:HasModifier("modifier_jakiro_fire_ball_magical_reduction") then --! Снижение маг. резиста от Fire Ball
                damage = damage - (damage / 100 * self:GetSpecialValueFor("ice_ball_damage_reduction_pct"))
                enemy:RemoveModifierByName("modifier_jakiro_fire_ball_magical_reduction")

                local modifires = {
                    "modifier_jakiro_dual_breath_new_ice", "modifier_jakiro_dual_breath_new_fire"
                }
                for _, mod in pairs(modifiers) do
                    if enemy:HasModifier(mod) then
                        enemy:FindModifierByName(mod):SetDuration(mod:GetDuration() - self:GetCaster():FindAbilityByName("jakiro_fire_ball"):GetSpecialValueFor("additional_duration"), true)
                    end
                end
            end
            ApplyDamage({
                victim = enemy,
                attacker = caster,
                ability = self,
                damage = damage,
                damage_type = self:GetAbilityDamageType()
            })
        end
    end
end

modifier_jakiro_ice_ball_freeze = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    IsPurgeException = function() return true end,
    CheckState = function() return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true
    }
    end
})

function modifier_jakiro_ice_ball_freeze:OnCreated()
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_jakiro_ice_ball_damage_reduction = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    IsPurgeException = function() return true end,
    DeclareFunctions = function() return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    } end
})

function modifier_jakiro_ice_ball_damage_reduction:GetModifierTotalDamageOutgoing_Percentage()
    return -self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end