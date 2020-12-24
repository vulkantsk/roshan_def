hoodwink_sharp_shoot = class({})

function hoodwink_sharp_shoot:GetCastRange()
	return self:GetSpecialValueFor("wave_distance")
end

function hoodwink_sharp_shoot:OnSpellStart()
	local caster = self:GetCaster()
   	
   	local index = RandomInt(1, 20)
    if index < 10 then
        index = "0"..index
    end
    caster:EmitSound("hoodwink_hoodwink_arb_hit_"..index)
    caster:EmitSound("Hero_Hoodwink.Sharpshooter.Projectile")

   	local vDirection = (self:GetCursorPosition() - caster:GetOrigin() + caster:GetForwardVector()):Normalized()
	
    local particle = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf"


    ProjectileManager:CreateLinearProjectile({
      EffectName = particle,
      Ability = self,
      vSpawnOrigin = self:GetCaster():GetOrigin(),
      fStartRadius = self:GetSpecialValueFor("wave_width_initial"),
      fEndRadius = self:GetSpecialValueFor("wave_width_end"),
      vVelocity = vDirection * self:GetSpecialValueFor("wave_speed"),
      fDistance = self:GetSpecialValueFor("wave_distance"),
      Source = self:GetCaster(),
      iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
      iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
--      iUnitTargetFlags = self:GetAbilityTargetFlags(),
      bProvidesVision = true,
      iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
      iVisionRadius = self:GetSpecialValueFor("wave_width_end"),
    })
	
    local base_dmg = self:GetSpecialValueFor("base_dmg")
    local damage_pct = self:GetSpecialValueFor("damage_pct")/100
  	self.wave_damage = base_dmg + caster:GetAverageTrueAttackDamage(caster)*damage_pct 
end

function hoodwink_sharp_shoot:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local caster = self:GetCaster()
		local stun_duration = self:GetSpecialValueFor("stun_duration")
		local debuff_duration = self:GetSpecialValueFor("debuff_duration")

--		EmitSoundOn("Hero_hoodwink.StormBoltImpact", hTarget)		
		PopupCriticalDamage(hTarget, self.wave_damage)
		DealDamage(caster, hTarget, self.wave_damage, self:GetAbilityDamageType(), DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, self)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})
	end
end


