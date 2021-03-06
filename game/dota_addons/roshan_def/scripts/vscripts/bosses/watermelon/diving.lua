LinkLuaModifier("modifier_watermelon_diving", "bosses/watermelon/diving", 0)

watermelon_diving = class({})

function watermelon_diving:OnSpellStart(up_and_down_time, underwater_time)
	local duration = self:GetSpecialValueFor("up_and_down_time") * 2 + self:GetSpecialValueFor("underwater_time")

	if up_and_down_time and underwater_time then
		duration = underwater_time + up_and_down_time*2
	elseif self:GetCaster():HasModifier("modifier_watermelon_madness") then
		duration = self:GetSpecialValueFor("up_and_down_time") * 2
	end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_watermelon_diving", {duration = duration})
	self.end_point = self:GetCaster():GetCursorPosition()

	if RollPercentage(50) then
		self:GetCaster():EmitSound("tidehunter_tide_blink_0"..RandomInt(1, 4))
	end

end

modifier_watermelon_diving = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	CheckState = function() return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_STUNNED] = true
	}
	end
})

function modifier_watermelon_diving:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self.bTeleported = false
	self.down_location = nil

	self:GetCaster():EmitSound("watermelon_diving")
end

function modifier_watermelon_diving:OnIntervalThink()
	local up_and_down_time = self:GetAbility():GetSpecialValueFor("up_and_down_time")
	if not IsServer() then return end
	if self:GetElapsedTime() <= up_and_down_time then
		self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() - Vector(0, 0, self:GetAbility():GetSpecialValueFor("speed")))
		self.down_location = self:GetCaster():GetAbsOrigin().z
	elseif self:GetElapsedTime() > up_and_down_time and self:GetRemainingTime() > up_and_down_time then
		if not self.bTeleported then
			self:GetCaster():SetAbsOrigin(self:GetAbility().end_point + Vector(0, 0, self.down_location))
			self.bTeleported = true
			
			self:GetCaster():EmitSound("watermelon_diving")
		end
	elseif self:GetRemainingTime() <= up_and_down_time then
		self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + Vector(0, 0, self:GetAbility():GetSpecialValueFor("speed")))
	end
end