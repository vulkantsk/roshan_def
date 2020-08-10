invoker_wex_alacrity = class({})
LinkLuaModifier('modifeir_invoker_wex_alacrity_buff', 'heroes/hero_invoker/invoker_wex_alacrity', LUA_MODIFIER_MOTION_NONE)

function invoker_wex_alacrity:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local base_as = self:GetSpecialValueFor("base_as")
    local agi_as = self:GetSpecialValueFor("agi_as")/100*caster:GetAgility()

    local modifier = target:AddNewModifier(caster, self, 'modifeir_invoker_wex_alacrity_buff', {duration = duration})
    modifier:SetStackCount(base_as+agi_as)

    self:GetCaster():EmitSound("Hero_Invoker.Alacrity")
    self:GetCaster():EmitSound("invoker_invo_ability_alacrity_0" .. RandomInt(1,4))
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ALACRITY)
end

modifeir_invoker_wex_alacrity_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,

    GetEffectName           = function(self) return 'particles/units/heroes/hero_invoker/invoker_alacrity.vpcf' end,
    GetEffectAttachType     = function(self) return PATTACH_OVERHEAD_FOLLOW end,

    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        }
    end,
})

function modifeir_invoker_wex_alacrity_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end 
function modifeir_invoker_wex_alacrity_buff:OnCreated()
    local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_alacrity_buff.vpcf', PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(nfx, true, false, 4, true, true)
end 

function modifeir_invoker_wex_alacrity_buff:OnRefresh()
    local abiltiy = self:GetAbility()
    self.caster = self:GetCaster()
end 