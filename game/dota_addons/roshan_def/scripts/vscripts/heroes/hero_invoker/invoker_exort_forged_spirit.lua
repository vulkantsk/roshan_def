invoker_exort_forged_spirit = class({})

function invoker_exort_forged_spirit:OnSpellStart()
    local caster = self:GetCaster()

    local unit = CreateUnitByName('npc_dota_invoker_forged_spirit_custom', caster:GetOrigin(), true, caster, caster, caster:GetTeam())
    unit:SetControllableByPlayer(caster:GetPlayerID(), false)
    unit:AddNewModifier(unit, nil, 'modifier_kill', {
        duration = self:GetSpecialValueFor('duration')
    })
    self:GetCaster():EmitSound("Hero_Invoker.ForgeSpirit")
    self:GetCaster():EmitSound("invoker_invo_ability_forgespirit_0" .. RandomInt(1,6))
    self:GetCaster():StartGesture(ACT_DOTA_CAST_FORGE_SPIRIT)
end 