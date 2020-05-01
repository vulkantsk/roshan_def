LinkLuaModifier( "wisp_powerup_dmg_counter", "heroes/hero_wisp/powerup.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff
LinkLuaModifier( "wisp_powerup_armor_counter", "heroes/hero_wisp/powerup.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff
LinkLuaModifier( "wisp_powerup_hp_counter", "heroes/hero_wisp/powerup.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff
LinkLuaModifier( "wisp_powerup_as_counter", "heroes/hero_wisp/powerup.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff
LinkLuaModifier( "wisp_powerup_ms_counter", "heroes/hero_wisp/powerup.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff

wisp_powerup_dmg = class({})

function wisp_powerup_dmg:GetIntrinsicModifierName()
	return "wisp_powerup_dmg_counter"
end

function wisp_powerup_dmg:GetGoldCost()
	local gold_per_upgrade = self:GetSpecialValueFor("gold_per_upgrade")
	local max_gold_upgrade = self:GetSpecialValueFor("max_gold_upgrade")
	local level = self:GetLevel()
	local gold_cost = gold_per_upgrade * level

	if gold_cost > max_gold_upgrade then
		gold_cost = max_gold_upgrade
	end
	return gold_cost
end

function wisp_powerup_dmg:OnSpellStart()
	local caster = self:GetCaster()
	local modifier_name = self:GetIntrinsicModifierName()
	local stack_count = caster:GetModifierStackCount(modifier_name, nil)
	local max_upgrade = self:GetSpecialValueFor("max_upgrade")			
	if stack_count >= max_upgrade then
		caster:ModifyGold(self:GetGoldCost(-1), false, 0)
		return
	end

	self:SetLevel(self:GetLevel()+1)
	caster:SetModifierStackCount(modifier_name, caster, stack_count + 1)
end

--------------------------------------------------------------------------------

wisp_powerup_dmg_counter = class({})

function wisp_powerup_dmg_counter:IsPurgable() return false 
end

function wisp_powerup_dmg_counter:IsHidden() return false
end

function wisp_powerup_dmg_counter:IsBuff() return true
end

--------------------------------------------------------------------------------
wisp_powerup_armor = class({})

function wisp_powerup_armor:GetIntrinsicModifierName()
	return "wisp_powerup_armor_counter"
end

function wisp_powerup_armor:GetGoldCost()
	local gold_per_upgrade = self:GetSpecialValueFor("gold_per_upgrade")
	local max_gold_upgrade = self:GetSpecialValueFor("max_gold_upgrade")
	local level = self:GetLevel()
	local gold_cost = gold_per_upgrade * level

	if gold_cost > max_gold_upgrade then
		gold_cost = max_gold_upgrade
	end
	return gold_cost
end

function wisp_powerup_armor:OnSpellStart()
	local caster = self:GetCaster()
	local modifier_name = self:GetIntrinsicModifierName()
	local stack_count = caster:GetModifierStackCount(modifier_name, nil)
	local max_upgrade = self:GetSpecialValueFor("max_upgrade")			
	if stack_count >= max_upgrade then
		caster:ModifyGold(self:GetGoldCost(-1), false, 0)
		return
	end

	self:SetLevel(self:GetLevel()+1)
	caster:SetModifierStackCount(modifier_name, caster, stack_count + 1)
end

--------------------------------------------------------------------------------

wisp_powerup_armor_counter = class({})

function wisp_powerup_armor_counter:IsPurgable() return false 
end

function wisp_powerup_armor_counter:IsHidden() return false
end

function wisp_powerup_armor_counter:IsBuff() return true
end

--------------------------------------------------------------------------------
wisp_powerup_hp = class({})

function wisp_powerup_hp:GetIntrinsicModifierName()
	return "wisp_powerup_hp_counter"
end

function wisp_powerup_hp:GetGoldCost()
	local gold_per_upgrade = self:GetSpecialValueFor("gold_per_upgrade")
	local max_gold_upgrade = self:GetSpecialValueFor("max_gold_upgrade")
	local level = self:GetLevel()
	local gold_cost = gold_per_upgrade * level

	if gold_cost > max_gold_upgrade then
		gold_cost = max_gold_upgrade
	end
	return gold_cost
end

function wisp_powerup_hp:OnSpellStart()
	local caster = self:GetCaster()
	local modifier_name = self:GetIntrinsicModifierName()
	local stack_count = caster:GetModifierStackCount(modifier_name, nil)
	local max_upgrade = self:GetSpecialValueFor("max_upgrade")			
	if stack_count >= max_upgrade then
		caster:ModifyGold(self:GetGoldCost(-1), false, 0)
		return
	end

	self:SetLevel(self:GetLevel()+1)
	caster:SetModifierStackCount(modifier_name, caster, stack_count + 1)
end

--------------------------------------------------------------------------------

wisp_powerup_hp_counter = class({})

function wisp_powerup_hp_counter:IsPurgable() return false 
end

function wisp_powerup_hp_counter:IsHidden() return false
end

function wisp_powerup_hp_counter:IsBuff() return true
end

--------------------------------------------------------------------------------
wisp_powerup_as = class({})

function wisp_powerup_as:GetIntrinsicModifierName()
	return "wisp_powerup_as_counter"
end

function wisp_powerup_as:GetGoldCost()
	local gold_per_upgrade = self:GetSpecialValueFor("gold_per_upgrade")
	local max_gold_upgrade = self:GetSpecialValueFor("max_gold_upgrade")
	local level = self:GetLevel()
	local gold_cost = gold_per_upgrade * level

	if gold_cost > max_gold_upgrade then
		gold_cost = max_gold_upgrade
	end
	return gold_cost
end

function wisp_powerup_as:OnSpellStart()
	local caster = self:GetCaster()
	local modifier_name = self:GetIntrinsicModifierName()
	local stack_count = caster:GetModifierStackCount(modifier_name, nil)
	local max_upgrade = self:GetSpecialValueFor("max_upgrade")			
	if stack_count >= max_upgrade then
		caster:ModifyGold(self:GetGoldCost(-1), false, 0)
		return
	end

	self:SetLevel(self:GetLevel()+1)
	caster:SetModifierStackCount(modifier_name, caster, stack_count + 1)
end


--------------------------------------------------------------------------------

wisp_powerup_as_counter = class({})

function wisp_powerup_as_counter:IsPurgable() return false 
end

function wisp_powerup_as_counter:IsHidden() return false
end

function wisp_powerup_as_counter:IsBuff() return true
end

--------------------------------------------------------------------------------
wisp_powerup_ms = class({})

function wisp_powerup_ms:GetIntrinsicModifierName()
	return "wisp_powerup_ms_counter"
end

function wisp_powerup_ms:GetGoldCost()
	local gold_per_upgrade = self:GetSpecialValueFor("gold_per_upgrade")
	local max_gold_upgrade = self:GetSpecialValueFor("max_gold_upgrade")
	local level = self:GetLevel()
	local gold_cost = gold_per_upgrade * level

	if gold_cost > max_gold_upgrade then
		gold_cost = max_gold_upgrade
	end
	return gold_cost
end

function wisp_powerup_ms:OnSpellStart()
	local caster = self:GetCaster()
	local modifier_name = self:GetIntrinsicModifierName()
	local stack_count = caster:GetModifierStackCount(modifier_name, nil)
	local max_upgrade = self:GetSpecialValueFor("max_upgrade")			
	if stack_count >= max_upgrade then
		caster:ModifyGold(self:GetGoldCost(-1), false, 0)
		return
	end

	self:SetLevel(self:GetLevel()+1)
	caster:SetModifierStackCount(modifier_name, caster, stack_count + 1)
end

--------------------------------------------------------------------------------

wisp_powerup_ms_counter = class({})

function wisp_powerup_ms_counter:IsPurgable() return false 
end

function wisp_powerup_ms_counter:IsHidden() return false
end

function wisp_powerup_ms_counter:IsBuff() return true
end

--------------------------------------------------------------------------------

modifier_wisp_powerup_dmg_buff = class({})

function modifier_wisp_powerup_dmg_buff:IsPurgable() return false 
end

function modifier_wisp_powerup_dmg_buff:IsHidden() return false
end

function modifier_wisp_powerup_dmg_buff:IsBuff() return true
end

function modifier_wisp_powerup_dmg_buff:DeclareFunctions()
    return {   
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE ,
--        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
       }
end

function modifier_wisp_powerup_dmg_buff:GetModifierPreAttack_BonusDamage()		-- Static + stacks	
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("upgrade_value")--self:GetStackCount()*2
end

function modifier_wisp_powerup_dmg_buff:GetModifierBaseAttack_BonusDamage()			-- Static + stacks
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("upgrade_value")--self:GetStackCount()*2
end

modifier_wisp_powerup_hp_buff = class({})

function modifier_wisp_powerup_hp_buff:IsPurgable() return false 
end

function modifier_wisp_powerup_hp_buff:IsHidden() return false
end

function modifier_wisp_powerup_hp_buff:IsBuff() return true
end

function modifier_wisp_powerup_hp_buff:DeclareFunctions()
    return {   
--        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
       }
end


function modifier_wisp_powerup_hp_buff:GetModifierExtraHealthPercentage()	
	return self:GetStackCount()
end

function modifier_wisp_powerup_hp_buff:GetModifierExtraHealthBonus()
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("upgrade_value")--self:GetStackCount()*2
end

modifier_wisp_powerup_armor_buff = class({})

function modifier_wisp_powerup_armor_buff:IsPurgable() return false 
end

function modifier_wisp_powerup_armor_buff:IsHidden() return false
end

function modifier_wisp_powerup_armor_buff:IsBuff() return true
end

function modifier_wisp_powerup_armor_buff:DeclareFunctions()
    return {   
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        }
end

function modifier_wisp_powerup_armor_buff:GetModifierPhysicalArmorBonus()			-- Static + stacks
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("upgrade_value")--self:GetStackCount()*2
end

modifier_wisp_powerup_as_buff = class({})

function modifier_wisp_powerup_as_buff:IsPurgable() return false 
end

function modifier_wisp_powerup_as_buff:IsHidden() return false
end

function modifier_wisp_powerup_as_buff:IsBuff() return true
end

function modifier_wisp_powerup_as_buff:DeclareFunctions()
    return {   
       MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        }
end

function modifier_wisp_powerup_as_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("upgrade_value")--self:GetStackCount()*2
end
 

modifier_wisp_powerup_ms_buff = class({})

function modifier_wisp_powerup_ms_buff:IsPurgable() return false 
end

function modifier_wisp_powerup_ms_buff:IsHidden() return false
end

function modifier_wisp_powerup_ms_buff:IsBuff() return true
end

function modifier_wisp_powerup_ms_buff:DeclareFunctions()
    return {   
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        }
end

function modifier_wisp_powerup_ms_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("upgrade_value")--self:GetStackCount()*2
end


 

