invoker_exort_forged_spirit = class({})

function invoker_exort_forged_spirit:OnSpellStart()
    local caster = self:GetCaster()

    local unit = CreateUnitByName('npc_dota_invoker_forged_spirit_custom', caster:GetOrigin(), true, caster, caster, caster:GetTeam())
    unit:SetControllableByPlayer(caster:GetPlayerID(), false)
    unit:AddNewModifier(unit, nil, 'modifier_kill', {
        duration = self:GetSpecialValueFor('duration')
    })

    self:GetCaster():StartGesture(ACT_DOTA_CAST_FORGE_SPIRIT)
end 