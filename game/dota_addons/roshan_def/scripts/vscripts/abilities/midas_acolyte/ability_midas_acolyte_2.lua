ability_midas_acolyte_2 = class({
	GetIntrinsicModifierName = function(self) return 'modifier_ability_midas_acolyte_2_aura' end,
})
LinkLuaModifier("modifier_ability_midas_acolyte_2_aura", 'abilities/midas_acolyte/ability_midas_acolyte_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_midas_acolyte_2_debuff", 'abilities/midas_acolyte/ability_midas_acolyte_2.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_midas_acolyte_2_aura = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return true end,
	IsPermanent             = function(self) return true end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self.radius end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchFlags      = function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
	GetAuraSearchType		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return 'modifier_ability_midas_acolyte_2_debuff' end,
	OnCreated 				= function(self)
		local ability = self:GetAbility()
		self.parent = self:GetParent()
		self.radius = ability:GetLevelSpecialValueFor('aura_radius',1)
		self.parent.heal = ability:GetLevelSpecialValueFor('heal',1)
		self.parent.damage = ability:GetLevelSpecialValueFor('damage',1)
		self.parent.gold = ability:GetLevelSpecialValueFor('gold_lose',1)
	end,
	GetAuraEntityReject 	= function(self,hEntity)
		return hEntity == self.parent
	end,
})

modifier_ability_midas_acolyte_2_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	AllowIllusionDuplicate	= function(self) return false end,
	IsPermanent             = function(self) return false end,

	OnCreated 				= function(self)
		local ability = self:GetAbility()
		self.ability = ability
		self.caster = self:GetCaster()
		local interval = 1
		self:StartIntervalThink(interval)
	end,

	OnIntervalThink 		= function(self)
		if IsClient() or self.ability:GetLevel() < 1 then return end
		local parent = self:GetParent()
		local gold = parent:GetGold()
		local caster = self.caster
		if parent == caster then return end
		if caster.gold > gold then return end

		ApplyDamage({
  			victim = parent,
  			attacker = caster,
  			damage = caster.damage,
  			damage_type = DAMAGE_TYPE_MAGICAL,
  			ability = self.ability,
		})

		local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)	
		ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

		caster.goldBonus = (caster.goldBonus or 0) + gold 

		parent:ModifyGold(-caster.gold, false, 0)

	end,
})