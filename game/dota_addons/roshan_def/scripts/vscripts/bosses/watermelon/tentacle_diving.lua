LinkLuaModifier("modifier_tentacle_checker", "bosses/watermelon/tentacle_diving", 0)

watermelon_tentacle_diving = class({})

function watermelon_tentacle_diving:OnSpellStart()
	local caster = self:GetCaster()
	for i = 1, 9 do
		if GetRandomAvailableWatermelonPoint() then
			caster:SetCursorPosition(GetRandomAvailableWatermelonPoint())
			caster:FindAbilityByName("watermelon_tentacle"):OnSpellStart()
		end
	end
	unit = CreateUnitByName("npc_dota_watermelon_tentacle", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster:AddNewModifier(caster, self, "modifier_tentacle_checker", nil)
end

modifier_tentacle_checker = class({
	IsHidden = function() return false end,
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

function modifier_tentacle_checker:OnCreated()
	if not IsServer() then return end
	self.arena_center = Entities:FindByName(nil, "BOSS_WM_POS_5"):GetAbsOrigin()
	self.bTentacleDestroyed = false
	self.iteration = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_tentacle_checker:OnIntervalThink()
	if not IsServer() then return end
	self.total_tentacle_health = 0
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.arena_center, nil, 2500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)) do
		if enemy:GetUnitName() == "npc_dota_watermelon_tentacle" then
			self.total_tentacle_health = self.total_tentacle_health + enemy:GetHealth()
		end
	end
	if self.iteration < 29 then
		self.iteration = self.iteration	+ 1
		self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() - Vector(0, 0, self:GetAbility():GetSpecialValueFor("speed")))
	elseif self.total_tentacle_health == 0 and not self.bTentacleDestroyed then
		self.iteration = self.iteration + 1
		self.bTentacleDestroyed = true
	elseif self.iteration == 30 or (self.iteration <= 59 and self.bTentacleDestroyed) then
		self.iteration = self.iteration + 1
		if self.iteration == 59 then
			self:Destroy()
		end
	end
end