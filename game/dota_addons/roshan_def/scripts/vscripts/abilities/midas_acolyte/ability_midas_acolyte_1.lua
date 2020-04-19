ability_midas_acolyte_1 = class({
	OnSpellStart = function(self)
		local caster = self.caster or self:GetCaster()
		local units = FindUnitsInRadius(caster:GetTeamNumber(), 
		caster:GetAbsOrigin(),
		nil,
		self:GetSpecialValueFor('radius'),
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
		local bonusHealth = #units * self:GetSpecialValueFor('bonus_health')
		local maxHealth = caster:GetMaxHealth()
		caster:SetBaseMaxHealth(maxHealth + bonusHealth)
		caster:SetMaxHealth(maxHealth + bonusHealth)
		caster:SetHealth(caster:GetHealth() + bonusHealth)

		caster:AddStackModifier({
			ability = self,
			modifier = 'modifier_ability_midas_acolyte_1_bonus_dmg',
			count = #units * self:GetSpecialValueFor('bonus_dmg'),
			caster = caster,
		})
	end,

	MidasActivate = function(self,target)
		self.caster = self.caster or self:GetCaster()
		local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
		ParticleManager:SetParticleControlEnt(midas_particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), false)
		target:KillTarget(caster, self)
	end,
})

LinkLuaModifier("modifier_ability_midas_acolyte_1_bonus_dmg", 'abilities/midas_acolyte/ability_midas_acolyte_1.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_midas_acolyte_1_bonus_dmg = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
    GetModifierPreAttack_BonusDamage = function(self) return self:GetStackCount() end,
})