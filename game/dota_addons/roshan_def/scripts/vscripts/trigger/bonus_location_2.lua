
function LocationEnter( keys )
	local target = keys.activator
	local team = target:GetTeam()
	local player = target:GetPlayerOwnerID()
	
	if team == DOTA_TEAM_NEUTRALS or target:IsCourier() then
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
