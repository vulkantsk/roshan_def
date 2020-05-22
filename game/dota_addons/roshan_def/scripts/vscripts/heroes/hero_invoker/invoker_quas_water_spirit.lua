invoker_quas_water_spirit = class({})

function invoker_quas_water_spirit:OnSpellStart()

	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local info = {
		EffectName = 'particles/units/heroes/hero_morphling/morphling_waveform.vpcf',
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = 0,
		fEndRadius = 0,
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
    if hTarget then return end

    local unit = CreateUnitByName('npc_dota_invoker_water_spirit_custom', vLocation, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam())
    unit:AddNewModifier(self:GetCaster(), self, 'modifier_kill', {
        duration = self:GetSpecialValueFor('duration'),
    })
    local newHealth = self:GetSpecialValueFor('health') + self:GetSpecialValueFor('health_bonus_mult') * .01 * self:GetCaster():GetStrength()
    unit:SetMaxHealth(newHealth)
    unit:SetBaseMaxHealth(newHealth)
    unit:SetHealth(newHealth)

    unit:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), false)
end 