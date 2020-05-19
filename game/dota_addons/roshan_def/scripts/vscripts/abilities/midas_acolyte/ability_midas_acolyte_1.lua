LinkLuaModifier("modifier_ability_midas_acolyte_1_bonus_dmg", 'abilities/midas_acolyte/ability_midas_acolyte_1.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_midas_acolyte_1_passive", 'abilities/midas_acolyte/ability_midas_acolyte_1.lua', LUA_MODIFIER_MOTION_NONE)

ability_midas_acolyte_1 = class({})

function ability_midas_acolyte_1:GetIntrinsicModifierName()
	return 'modifier_ability_midas_acolyte_1_passive'
end

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
 })

function modifier_ability_midas_acolyte_1_passive:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
   	self.radius = self.ability:GetSpecialValueFor('radius')
	self.bonus_health = self.ability:GetSpecialValueFor('bonus_health')
	self.bonus_dmg = self.ability:GetSpecialValueFor('bonus_dmg')
end

function modifier_ability_midas_acolyte_1_passive:OnAttackLanded(data)
	local target = data.target
	local attacker = data.attacker
	if target == self.parent and not attacker:IsBuilding() and not attacker:IsControllableByAnyPlayer() and attacker:GetTeam() ~= DOTA_TEAM_NEUTRALS  then 
		self:MidasActivate(attacker)
--    		self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
	end
end

function modifier_ability_midas_acolyte_1_passive:MidasActivate(target)		
	local caster = self.parent
	local bonusHealth = self.bonus_health
	local maxHealth = caster:GetMaxHealth()
	caster:SetBaseMaxHealth(maxHealth + bonusHealth)
	caster:SetMaxHealth(maxHealth + bonusHealth)
	caster:SetHealth(caster:GetHealth() + bonusHealth)
	caster:AddStackModifier({
		ability = self,
		modifier = 'modifier_ability_midas_acolyte_1_bonus_dmg',
		count = self.bonus_dmg,
		caster = caster,
	})
	caster:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), false)
	target:KillTarget(self.parent, self)
end