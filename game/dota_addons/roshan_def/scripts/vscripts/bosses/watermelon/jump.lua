LinkLuaModifier("modifier_watermelon_jump", "bosses/watermelon/jump", 3)

watermelon_jump = class({})

function watermelon_jump:GetAOERadius()
  return self:GetSpecialValueFor("damage_radius")
end

function watermelon_jump:OnSpellStart()
	local kv = {
		vPosX = self:GetCursorPosition().x,
		vPosY = self:GetCursorPosition().y,
		vPosZ = self:GetCursorPosition().z
	}
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_watermelon_jump", kv)

  if not self:GetCaster():HasModifier("modifier_watermelon_madness") and RollPercentage(50) then
    self:GetCaster():EmitSound("tidehunter_tide_move_0"..RandomInt(1, 9))
  end

   self:GetCaster():EmitSound("watermelon_jump")
end

modifier_watermelon_jump = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	IsStunDebuff = function() return true end,
	RemoveOnDeath = function() return true end,
	CheckState = function() return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true
	} end,
	DeclareFunctions = function() return {

	} end
})

if IsServer() then
	function modifier_watermelon_jump:OnCreated(kv)
		local height = self:GetAbility():GetSpecialValueFor("height")
		self.TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST = height
		self.TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST = height
		self.TECHIES_ACCELERATION_Z = 4000
		self.TECHIES_MAX_HORIZONTAL_ACCELERATION = height


        self.bHorizontalMotionInterrupted = false

        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end


        self.vStartPosition = GetGroundPosition(self:GetParent():GetOrigin(), self:GetParent())
        self.flCurrentTimeHoriz = 0.0
        self.flCurrentTimeVert = 0.0

        self.vLoc = Vector(kv.vPosX, kv.vPosY, kv.vPosZ)
        self.vLastKnownTargetPos = self.vLoc

        local duration = self:GetAbility():GetSpecialValueFor("duration")
        local flDesiredHeight = self.TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST * duration * duration
        local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + self.TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST )

        local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
        self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * self.TECHIES_ACCELERATION_Z )

        local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
        local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * self.TECHIES_ACCELERATION_Z * flDeltaZ ) )
        self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / self.TECHIES_ACCELERATION_Z, ( self.flInitialVelocityZ - flSqrtDet) / self.TECHIES_ACCELERATION_Z )

        self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
        self.vHorizontalVelocity.z = 0.0

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash_a.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
        ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetAbsOrigin())
        self:AddParticle( nFXIndex, false, false, -1, false, false )
       
       local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_generic_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
        ParticleManager:SetParticleControl(nFXIndex, 0, self.vLoc)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(self:GetAbility():GetSpecialValueFor("damage_radius"), 0, 0))
        ParticleManager:SetParticleControl(nFXIndex, 2, Vector(duration, 1, 1))
        ParticleManager:SetParticleControl(nFXIndex, 3, Vector(255, 215, 0))
        ParticleManager:SetParticleControl(nFXIndex, 4, Vector(255, 215, 0))
        self:AddParticle( nFXIndex, false, false, -1, false, false )
	end

	function modifier_watermelon_jump:UpdateHorizontalMotion( me, dt )
       	self.flCurrentTimeHoriz = math.min( self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime )
       	local t = self.flCurrentTimeHoriz / self.flPredictedTotalTime
       	local vStartToTarget = self.vLastKnownTargetPos - self.vStartPosition
       	local vDesiredPos = self.vStartPosition + t * vStartToTarget

       	local vOldPos = me:GetOrigin()
       	local vToDesired = vDesiredPos - vOldPos
       	vToDesired.z = 0.0
       	local vDesiredVel = vToDesired / dt
       	local vVelDif = vDesiredVel - self.vHorizontalVelocity
       	local flVelDif = vVelDif:Length2D()
       	vVelDif = vVelDif:Normalized()
       	local flVelDelta = math.min( flVelDif, self.TECHIES_MAX_HORIZONTAL_ACCELERATION )

       	self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
       	local vNewPos = vOldPos + self.vHorizontalVelocity * dt
       	me:SetOrigin( vNewPos )
	end

	function modifier_watermelon_jump:UpdateVerticalMotion( me, dt )
        self.flCurrentTimeVert = self.flCurrentTimeVert + dt
        local bGoingDown = ( -self.TECHIES_ACCELERATION_Z * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0
        local vNewPos = me:GetOrigin()
        vNewPos.z = self.vStartPosition.z + ( -0.5 * self.TECHIES_ACCELERATION_Z * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

        local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
        local bLanded = false
        if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
            vNewPos.z = flGroundHeight
            bLanded = true
        end

        me:SetOrigin( vNewPos )
        if bLanded == true then
            self.vNewPos = vNewPos
            self:GetParent():RemoveHorizontalMotionController( self )
            self:GetParent():RemoveVerticalMotionController( self )

            self:SetDuration( 0.05, false)
	    end
	end

	function modifier_watermelon_jump:OnHorizontalMotionInterrupted()
        self.bHorizontalMotionInterrupted = true
	end

	function modifier_watermelon_jump:OnVerticalMotionInterrupted()
        self:Destroy()
end

	function modifier_watermelon_jump:OnDestroy()
		local parent = self:GetParent()
        parent:RemoveHorizontalMotionController( self )
		parent:RemoveVerticalMotionController( self )
		local enemies_in_radius = FindUnitsInRadius(parent:GetTeamNumber(), self.vNewPos, nil, self:GetAbility():GetSpecialValueFor("damage_radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)
		for _, enemy in pairs(enemies_in_radius) do
			ApplyDamage({
				victim = enemy,
				attacker = parent,
				ability = self:GetAbility(),
				damage = self:GetAbility():GetSpecialValueFor("damage"),
				damage_type = self:GetAbility():GetAbilityDamageType()
			})
		end
    
    local friends_in_radius = FindUnitsInRadius(parent:GetTeamNumber(), self.vNewPos, nil, 300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)

    for _, friend in pairs(friends_in_radius) do
      if friend:GetUnitName() == "npc_dota_watermelon_tentacle" then
        friend:ForceKill(false)
      end
    end

    self:GetCaster():SetAbsOrigin(self.vNewPos)

	end
end