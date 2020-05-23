invoker_wex_wind_walk = class({})
LinkLuaModifier("modifier_invoker_wex_wind_walk_buff", "heroes/hero_invoker/invoker_wex_wind_walk", LUA_MODIFIER_MOTION_NONE)
function invoker_wex_wind_walk:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, 'modifier_invoker_wex_wind_walk_buff', {duration = duration})

    caster:EmitSound("invoker_invo_ability_ghostwalk_0" .. RandomInt(1, 5))
    caster:StartGesture(ACT_DOTA_CAST_GHOST_WALK)
    ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
end

modifier_invoker_wex_wind_walk_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    CheckState              = function(self)
        return {
--            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        }
    end,
    DeclareFunctions        = function(self) return 
        {   MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end,
})

function modifier_invoker_wex_wind_walk_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_invoker_wex_wind_walk_buff:GetModifierInvisibilityLevel()
    return 0.4
end
