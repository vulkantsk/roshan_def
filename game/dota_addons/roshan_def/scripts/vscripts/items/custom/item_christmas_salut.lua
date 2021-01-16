LinkLuaModifier("modifier_item_christmas_salut_aura", "items/custom/item_christmas_salut", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_christmas_salut", "items/custom/item_christmas_salut", LUA_MODIFIER_MOTION_NONE)

item_christmas_salut = class({})

function item_christmas_salut:GetIntrinsicModifierName()
    return "modifier_item_christmas_salut"
end

function item_christmas_salut:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function item_christmas_salut:OnSpellStart()
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local bomb_interval = self:GetSpecialValueFor("bomb_interval")
    local bomb_count = self:GetSpecialValueFor("bomb_count")
    local radius = self:GetSpecialValueFor("radius")

    
    for i=1,bomb_count do
        Timers:CreateTimer(i*bomb_interval,function()
            local target_point = point + RandomVector(RandomInt(0, radius))
            local thinker = CreateModifierThinker(caster, self, "modifier_phased", nil, target_point, caster:GetTeam(), false)
             ProjectileManager:CreateTrackingProjectile({
                Target = thinker,
                Source = caster,
                Ability = self,
                EffectName = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare.vpcf",
                bDodgeable = false,
                bProvidesVision = true,
                iMoveSpeed = 1500,
                iVisionRadius = 250,
                iVisionTeamNumber = caster:GetTeamNumber(),
            })  
        end)
    end

end

function item_christmas_salut:OnProjectileHit(hTarget, vLocation)
    if hTarget then
        local caster = self:GetCaster()
        local bomb_radius = self:GetSpecialValueFor("bomb_radius")
        local bomb_damage = self:GetSpecialValueFor("bomb_damage")
        hTarget:EmitSound("christmas_salut_explode")

        local enemies = caster:FindEnemyUnitsInRadius(vLocation, bomb_radius, nil)
        for _,enemy in ipairs(enemies) do
            DealDamage(caster, enemy, bomb_damage, DAMAGE_TYPE_MAGICAL, nil, self)
        end
        hTarget:RemoveSelf()
    end
end

modifier_item_christmas_salut = class({
    IsHidden = function() return true end,
    DeclareFunctions = function() return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }end,
})

function modifier_item_christmas_salut:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_christmas_salut:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_as")
end
