invoker_quas_water_spirit = class({})

function invoker_quas_water_spirit:OnSpellStart()
	local radius = self:GetSpecialValueFor("radius")
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local info = {
		EffectName = 'particles/units/heroes/hero_morphling/morphling_waveform.vpcf',
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = radius,
		fEndRadius = radius,
		vVelocity = vDirection * 1200,
		fDistance = #(self:GetCursorPosition() - self:GetCaster():GetOrigin()), -- transform 2D
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}

	ProjectileManager:CreateLinearProjectile( info )
    EmitSoundOn("Hero_Morphling.Waveform", self:GetCaster())
end 

function invoker_quas_water_spirit:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
    if hTarget then 
		local damage = self:GetSpecialValueFor("damage")
		DealDamage(caster, hTarget, damage, self:GetAbilityDamageType(), nil, self)
    	return 
    end
    local duration = self:GetSpecialValueFor('duration')
    local unit = CreateUnitByName('npc_dota_invoker_water_spirit_custom', vLocation, true, caster, caster, caster:GetTeam())
    unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    unit:AddNewModifier(caster, self, 'modifier_kill', {duration = duration})
    
    local base_health = self:GetSpecialValueFor('health')
    local str_health = self:GetSpecialValueFor('health_bonus_mult')/100 * caster:GetStrength()
    local total_health = base_health + str_health
    unit:SetMaxHealth(total_health)
    unit:SetBaseMaxHealth(total_health)
    unit:SetHealth(total_health)

end 