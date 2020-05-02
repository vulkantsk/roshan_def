ability_killer_4 = class({
	GetIntrinsicModifierName = function(self) return 'modifier_ability_killer_4_passive' end,
})
LinkLuaModifier("modifier_ability_killer_4_passive", 'abilities/killer/ability_killer_4.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_killer_4_stacks", 'abilities/killer/ability_killer_4.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_killer_4_buff", 'abilities/killer/ability_killer_4.lua', LUA_MODIFIER_MOTION_NONE)


modifier_ability_killer_4_stacks = class({})
function modifier_ability_killer_4_stacks:IsHidden() return false end
function modifier_ability_killer_4_stacks:IsPurgable() return true end
function modifier_ability_killer_4_stacks:IsDebuff() return true end
function modifier_ability_killer_4_stacks:IsBuff() return true end
function modifier_ability_killer_4_stacks:RemoveOnDeath() return true end
function modifier_ability_killer_4_stacks:IsPermanent() return false end

modifier_ability_killer_4_buff = class({})
function modifier_ability_killer_4_buff:IsHidden() return false end
function modifier_ability_killer_4_buff:IsPurgable() return true end
function modifier_ability_killer_4_buff:IsDebuff() return false end
function modifier_ability_killer_4_buff:IsBuff() return true end
function modifier_ability_killer_4_buff:RemoveOnDeath() return true end
function modifier_ability_killer_4_buff:IsPermanent() return false end
function modifier_ability_killer_4_buff:GetEffectAttachType() return PATTACH_ABSORIGIN end
function modifier_ability_killer_4_buff:GetEffectName() return 'particles/econ/items/drow/drow_head_mania/mask_of_madness_active_mania.vpcf' end
function modifier_ability_killer_4_buff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_ability_killer_4_buff:GetModifierAttackSpeedBonus_Constant() return self.atk end
function modifier_ability_killer_4_buff:OnCreated()
    if IsClient() then return end
    self.atk = self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

modifier_ability_killer_4_passive = class({})
function modifier_ability_killer_4_passive:IsHidden() return true end
function modifier_ability_killer_4_passive:IsPurgable() return false end
function modifier_ability_killer_4_passive:IsDebuff() return false end
function modifier_ability_killer_4_passive:IsBuff() return true end
function modifier_ability_killer_4_passive:RemoveOnDeath() return true end
function modifier_ability_killer_4_passive:IsPermanent() return true end
function modifier_ability_killer_4_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_ability_killer_4_passive:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.attackNeed = self.ability:GetSpecialValueFor('amount_attack')
    self.bonus_attack_speed = self.ability:GetSpecialValueFor('bonus_attack_speed')
    self.duration = self.ability:GetSpecialValueFor('duration')
end

function modifier_ability_killer_4_passive:OnAttackLanded(data)
    if data.attacker == self.parent and self.ability:GetLevel() > 0 and not self.parent:HasModifier('modifier_ability_killer_4_buff') then 

        local stacks = self.parent:AddStackModifier({
            ability = self.ability,
            modifier = 'modifier_ability_killer_4_stacks',
            caster = self.parent,
        })

        if stacks >= self.attackNeed then 
            local modifier = self.parent:FindModifierByName('modifier_ability_killer_4_stacks')
            if modifier then  
                modifier:Destroy()

            self.parent:AddNewModifier(self.parent, self.ability, 'modifier_ability_killer_4_buff', {duration = self.duration})
            end
        end

    end
end
