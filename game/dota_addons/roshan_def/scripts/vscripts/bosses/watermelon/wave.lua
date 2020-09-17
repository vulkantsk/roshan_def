watermelon_wave = class({})

function watermelon_wave:OnSpellStart()
	self.bLocationSetup = false
	self.vLocation = nil
	self.vCasterPosition = self:GetCaster():GetAbsOrigin()
	ProjectileManager:CreateLinearProjectile({
		EffectName = "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf",
      	Ability = self,
      	vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
      	fStartRadius = self:GetSpecialValueFor("wave_width"),
      	fEndRadius = self:GetSpecialValueFor("wave_width"),
      	vVelocity = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("wave_speed"),
      	fDistance = (self:GetCaster():GetAbsOrigin() - self:GetCursorPosition()):Length2D(),
      	Source = self:GetCaster(),
      	iUnitTargetTeam = self:GetAbilityTargetTeam(),
      	iUnitTargetType = self:GetAbilityTargetType(),
		iUnitTargetFlags = self:GetAbilityTargetFlags(),
		ExtraData = {
			ProjectileNumber = 1
		}
	})
end

function watermelon_wave:OnProjectileHit_ExtraData(target, location, ExtraData)
	if target then
		ApplyDamage({
			victim = target,
			attacker = self:GetCaster(),
			ability = self,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType()
		})
	elseif target == nil then
		if not self.bLocationSetup then
			self.location = location
			self.bLocationSetup = true
		end
		if ExtraData.ProjectileNumber == 1 then
			ProjectileManager:CreateLinearProjectile({
				EffectName = "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf",
      			Ability = self,
      			vSpawnOrigin = self.location,
      			fStartRadius = self:GetSpecialValueFor("wave_width"),
      			fEndRadius = self:GetSpecialValueFor("wave_width"),
      			vVelocity = (self.vCasterPosition - self.location):Normalized() * self:GetSpecialValueFor("wave_speed"),
      			fDistance = (self.location - self.vCasterPosition):Length2D(),
      			Source = self:GetCaster(),
      			iUnitTargetTeam = self:GetAbilityTargetTeam(),
      			iUnitTargetType = self:GetAbilityTargetType(),
				iUnitTargetFlags = self:GetAbilityTargetFlags()
			})
			ExtraData.ProjectileNumber = 2
		end
	end
end