ability_midas_acolyte_1 = class({
	GetIntrinsicModifierName = function(self) return 'modifier_ability_midas_acolyte_1_passive' end,
})

LinkLuaModifier("modifier_ability_midas_acolyte_1_bonus_dmg", 'abilities/midas_acolyte/ability_midas_acolyte_1.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_midas_acolyte_1_passive", 'abilities/midas_acolyte/ability_midas_acolyte_1.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_midas_acolyte_1_bonus_dmg = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
    GetModifierPreAttack_BonusDamage = function(self) return self:GetStackCount() end,
})

modifier_ability_midas_acolyte_1_passive = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
    OnCreated 				= function(self)
    	self.parent = self:GetParent()
    	self.ability = self:GetAbility()
    	self.radius = self.ability:GetLevelSpecialValueFor('radius',1)
    	self.bonus_health = self.ability:GetLevelSpecialValueFor('bonus_health',1)
    	self.bonus_dmg = self.ability:GetLevelSpecialValueFor('bonus_dmg',1)
    end,
    OnAttackLanded 			= function(self,data)
    	if self.ability:IsCooldownReady() and data.target == self.parent and self.ability:GetLevel() > 0 then 
    		self:OnSpellStart()
    		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
    	end
    end,

	OnSpellStart = function(self)
		local caster = self.parent
		local units = FindUnitsInRadius(caster:GetTeamNumber(), 
		caster:GetAbsOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_CREEP, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		FIND_CLOSEST, 
		false)
		for k,v in pairs(units) do
			if v:GetOwnerEntity() or v:IsBoss() then 
				table.remove(units,k)
			end
		end
		if #units < 1 then return end
		caster:EmitSound("DOTA_Item.Hand_Of_Midas")
		for k,v in pairs(units) do
			self:MidasActivate(v)
		end
		local bonusHealth = #units * self.bonus_health
		local maxHealth = caster:GetMaxHealth()
		caster:SetBaseMaxHealth(maxHealth + bonusHealth)
		caster:SetMaxHealth(maxHealth + bonusHealth)
		caster:SetHealth(caster:GetHealth() + bonusHealth)

		caster:AddStackModifier({
			ability = self,
			modifier = 'modifier_ability_midas_acolyte_1_bonus_dmg',
			count = #units * self.bonus_dmg,
			caster = caster,
		})
	end,

	MidasActivate = function(self,target)
		local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
		ParticleManager:SetParticleControlEnt(midas_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), false)
		target:KillTarget(self.parent, self)
	end,
})