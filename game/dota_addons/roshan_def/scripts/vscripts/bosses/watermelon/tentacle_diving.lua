LinkLuaModifier("modifier_tentacle_checker", "bosses/watermelon/tentacle_diving", 0)
LinkLuaModifier("modifier_tentacle_diving", "bosses/watermelon/tentacle_diving", 0)

watermelon_tentacle_diving = class({})

function watermelon_tentacle_diving:OnSpellStart()
	local caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	caster:AddNewModifier(caster, self, "modifier_tentacle_checker", nil)

	local watermelon_points = Entities:FindAllByName("BOSS_WM_POINT")
	for _,wm_point in pairs(watermelon_points) do
		local position = wm_point:GetAbsOrigin()
		if wm_point.tentacle  then			
			wm_point.tentacle:ForceKill(false)
		end
		local unit = CreateUnitByName("npc_dota_watermelon_tentacle", position, false, caster, caster, caster:GetTeamNumber())
		unit:SetAbsOrigin(position)
		wm_point.tentacle = unit
	end
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
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	self.up_and_down_time = ability:GetSpecialValueFor("up_and_down_time")

	caster:AddNewModifier(caster, ability, "modifier_tentacle_diving", {duration = self.up_and_down_time, down = true})
	self:StartIntervalThink(FrameTime())
end

function modifier_tentacle_checker:OnIntervalThink()
	if not IsServer() then return end
	
	local watermelon_points = Entities:FindAllByName("BOSS_WM_POINT")
	for index,wm_point in pairs(watermelon_points) do
		if wm_point.tentacle then
			return
		end
	end
	self.old_point = self:GetCaster():GetAbsOrigin()
	self:Destroy()
end

function modifier_tentacle_checker:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local old_point = self.old_point
	local new_point = ability.point

	caster:SetAbsOrigin(Vector(new_point.x, new_point.y, old_point.z))
	caster:AddNewModifier(caster, ability, "modifier_tentacle_diving", {duration = self.up_and_down_time})

	self:GetCaster():EmitSound("tidehunter_tide_kill_0"..RandomInt(1, 9))
end

modifier_tentacle_diving = class({
	IsHidden = function(self) return true end,
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

function modifier_tentacle_diving:OnCreated(data)
	local ability = self:GetAbility()
	local tick_interval = ability:GetSpecialValueFor("tick_interval")
	self.speed = ability:GetSpecialValueFor("dive_range")/ability:GetSpecialValueFor("up_and_down_time")*tick_interval
	if data.down == 1 then
		self.speed = self.speed *(-1)
	end

	self:StartIntervalThink(tick_interval)
end

function modifier_tentacle_diving:OnIntervalThink()
	local caster = self:GetCaster()
	caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,self.speed))
end