LinkLuaModifier("modifier_watermelon_moving", "bosses/watermelon/moving.lua", 1)

watermelon_moving = class({})

function watermelon_moving:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

function watermelon_moving:GetChannelTime()
	return self:GetSpecialValueFor("move_delay")
end

function watermelon_moving:OnSpellStart()
	local duration = self:GetSpecialValueFor("move_delay") + self:GetSpecialValueFor("move_duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_watermelon_moving", {duration = duration})
	
	EmitSoundOn("sonic_race",self:GetCaster())
end

function watermelon_moving:OnChannelFinish(bInterrupted)
	StopSoundOn("sonic_race",self:GetCaster())
	self:GetCaster():EmitSound("watermelon_race")
end


modifier_watermelon_moving = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}end,
})

function modifier_watermelon_moving:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_watermelon_moving:OnCreated()
	if not IsServer() then return end
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end
	self.hit = {}

--	local target_point = GetRandomAvailableWatermelonPoint()
	self.face_towards = self:GetCaster():GetCursorPosition()
	local distance = (self.face_towards - self:GetCaster():GetAbsOrigin()):Length2D()
	self.speed = distance / self:GetAbility():GetSpecialValueFor("move_duration")
	self.direction = (self.face_towards - self:GetCaster():GetAbsOrigin()):Normalized()
	self:StartIntervalThink(FrameTime())
--	self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)
end

function modifier_watermelon_moving:OnIntervalThink()
	if not IsServer() then return end
	local enemies_in_radius = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("damage_radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), 0, false)
	for _, enemy in pairs(enemies_in_radius) do
		if not self.hit[enemy] then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = self:GetAbility():GetSpecialValueFor("damage"),
				damage_type = self:GetAbility():GetAbilityDamageType()
			})
			self.hit[enemy] = true
		end
	end
	self:GetCaster():FaceTowards(self.face_towards)
end

function modifier_watermelon_moving:UpdateHorizontalMotion(me, dt)
	if not IsServer() then return end
	local direction = self.direction
	local speed = self.speed
	if self:GetElapsedTime() > self:GetAbility():GetSpecialValueFor("move_delay") then
		me:SetOrigin(me:GetOrigin() + direction * speed * dt)
	end
end

function modifier_watermelon_moving:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
	self:Destroy()
end

function modifier_watermelon_moving:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end

function modifier_watermelon_moving:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():RemoveHorizontalMotionController(self)
	if self:GetCaster():HasModifier(self:GetName()) then
		RemoveModifierByName(self:GetName())
	end
--	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
end