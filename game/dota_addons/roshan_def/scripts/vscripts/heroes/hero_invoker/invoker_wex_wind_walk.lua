invoker_wex_wind_walk = class({})
LinkLuaModifier("modifier_invoker_wex_wind_walk_buff", "heroes/hero_invoker/invoker_wex_wind_walk", LUA_MODIFIER_MOTION_NONE)
function invoker_wex_wind_walk:OnSpellStart()

    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_invoker_wex_wind_walk_buff', {
        duration = self:GetSpecialValueFor('duration'),
    })

    self:GetCaster():StartGesture(ACT_DOTA_CAST_ALACRITY)
end

modifier_invoker_wex_wind_walk_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    CheckState              = function(self)
        return {
            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_FLYING] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        }
    end,
})
