LinkLuaModifier("modifier_ability_thief_4_passive", 'abilities/thief/ability_thief_4.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thief_4_stacks", 'abilities/thief/ability_thief_4.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thief_4_buff", 'abilities/thief/ability_thief_4.lua', LUA_MODIFIER_MOTION_NONE)

ability_thief_4 = class({})

function ability_thief_4:GetIntrinsicModifierName()
    return 'modifier_ability_thief_4_passive'
end

modifier_ability_thief_4_stacks = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,
})

modifier_ability_thief_4_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,
    DeclareFunctions 		= function(self)
    	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    end,
})

function modifier_ability_thief_4_buff:OnCreated() 
    self.atk = self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_ability_thief_4_buff:GetEffectAttachType() 
    return PATTACH_ABSORIGIN
end

function modifier_ability_thief_4_buff:GetEffectName() 
    return 'particles/econ/items/drow/drow_head_mania/mask_of_madness_active_mania.vpcf'
end

function modifier_ability_thief_4_buff:GetModifierAttackSpeedBonus_Constant() 
    return self.atk
end

modifier_ability_thief_4_passive = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return true end,
    DeclareFunctions  		= function(self)
    	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
    end,
})

function modifier_ability_thief_4_passive:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.attackNeed = self.ability:GetSpecialValueFor('amount_attack')
    self.bonus_attack_speed = self.ability:GetSpecialValueFor('bonus_attack_speed')
    self.duration = self.ability:GetSpecialValueFor('duration')
end

function modifier_ability_thief_4_passive:OnAttackLanded(data)
    if data.attacker == self.parent and  not self.parent:HasModifier('modifier_ability_thief_4_buff') then 
        local stacks = self.parent:AddStackModifier({
            ability = self.ability,
            modifier = 'modifier_ability_thief_4_stacks',
            caster = self.parent,
        })

        if stacks >= self.attackNeed then 
            local modifier = self.parent:FindModifierByName('modifier_ability_thief_4_stacks')
            if modifier then  
                modifier:Destroy()

            self.parent:AddNewModifier(self.parent, self.ability, 'modifier_ability_thief_4_buff', {duration = self.duration})
            end
        end

    end
end
