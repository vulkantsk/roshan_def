LinkLuaModifier("modifier_watermelon_passive", "bosses/watermelon/tentacle", 0)
LinkLuaModifier("modifier_watermelon_portal", "bosses/watermelon/tentacle", 0)

watermelon_tentacle = class({})

function watermelon_tentacle:GetIntrinsicModifierName()
	return "modifier_watermelon_passive"
end

function watermelon_tentacle:OnSpellStart()
	local position = self:GetCursorPosition()
	local caster = self:GetCaster()
	local wm_point
	local nearest_point = Entities:FindByNameNearest("BOSS_WM_POINT", position, 1000)

	if nearest_point then
		wm_point = nearest_point
	end
	if wm_point then
		position = wm_point:GetAbsOrigin()
		if wm_point.tentacle then
			wm_point.tentacle:ForceKill(false)
		end
	end

	local unit = CreateUnitByName("npc_dota_watermelon_tentacle", position, false, caster, caster, caster:GetTeam())
	if wm_point then
		wm_point.tentacle = unit
	end
end

function watermelon_tentacle:OnOwnerDied()
	self:GetCaster().thinker.active = true
	self:GetCaster():EmitSound("tidehunter_tide_death_0"..RandomInt(1, 9))
end

modifier_watermelon_passive = class({
	IsHidden = function(self) return true end,
})

function modifier_watermelon_passive:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true 
	}
	if not self:GetCaster().bInitialized then
		state[MODIFIER_STATE_DISARMED] = true
	end

	return state
end

modifier_watermelon_portal = {
	IsHidden = function(self) return true end,
}

function modifier_watermelon_portal:OnCreated()
	self.parent = self:GetParent()

	self:StartIntervalThink(0.25)
end

function modifier_watermelon_portal:OnIntervalThink()
    if self.parent.active then
	    if not self.portal_pfx then
	    	self:ActivatePortal()
	    end

	    local parent = self.parent
	    local team = parent:GetTeam()
	    local point = parent:GetAbsOrigin()
	    local units = FindUnitsInRadius(parent:GetTeamNumber(), point, nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)

	    for _, target in pairs(units) do
			local team = target:GetTeam()
			local player = target:GetPlayerOwnerID()
			
			if team == DOTA_TEAM_NEUTRALS then
				return
			end

			local point_name = "BOSS_WM_PORTAL_START"
		--	local modifier = "modifier_item_chicken_game_ticket"
			local point =  Entities:FindByName( nil, point_name):GetAbsOrigin()
			 
			FindClearSpaceForUnit(target, point, false)
			target:Stop()
			if not target:IsRealHero() then
				return
			end
			
			PlayerResource:SetCameraTarget(player, target)
			Timers:CreateTimer(0.1, function()
				PlayerResource:SetCameraTarget(player, nil) -- Чтобы камера разблочилась, т.к. она начинает следовать за игроком постоянно.
			end)
	    end
	elseif self.portal_pfx then
		ParticleManager:DestroyParticle(self.portal_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.portal_pfx)
	end

end

function modifier_watermelon_portal:ActivatePortal()
	local parent = self.parent
	local point = parent:GetAbsOrigin()
	local effect = "particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015.vpcf"
	self.portal_pfx = ParticleManager:CreateParticle( effect, PATTACH_WORLDORIGIN, parent )
	ParticleManager:SetParticleControl(self.portal_pfx, 0, point)
	ParticleManager:SetParticleControl(self.portal_pfx, 1, point)
	ParticleManager:SetParticleControl(self.portal_pfx, 2, point)
end