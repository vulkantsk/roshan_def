--LinkLuaModifier( "modifier_fow_vision", "modifiers/modifier_fow_vision", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	PointAbility = thisEntity:FindAbilityByName( "brotherhood_acid_spray" )
	TargetAbility = thisEntity:FindAbilityByName( "bristleback_viscous_nasal_goo" )

	thisEntity:SetContextThink( "BrotherhoodThink4", BrotherhoodThink4, 1 )
end

function BrotherhoodThink4()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end
	
	if GameRules:IsGamePaused() == true then
		return 1
	end

	local waypoint = Entities:FindByName( nil, "d_waypoint20") -- Записываем в переменную 'waypoint' координаты бокса d_waypoint19

	-- Increase acquisition range after the initial aggro

	local enemies = FindUnitsInRadius( 
									thisEntity:GetTeamNumber(),	--команда юнита
									thisEntity:GetOrigin(),		--местоположение юнита
									nil,	--айди юнита (необязательно)
									600,	--радиус поиска
									DOTA_UNIT_TARGET_TEAM_ENEMY,	-- юнитов чьей команды ищем вражеской/дружественной
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	--юнитов какого типа ищем 
									DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	--поиск по флагам
									FIND_CLOSEST,	--сортировка от ближнего к дальнему или от дальнего к ближнему
									false )

	if #enemies > 0 	then
		local health_pct = thisEntity:GetHealthPercent()

		if PointAbility ~= nil and PointAbility:IsFullyCastable() then
			return CastPointAbility( enemies[ 1 ] )
		end

		if TargetAbility ~= nil and TargetAbility:IsFullyCastable() then
			return CastTargetAbility( enemies[ 1 ] )
		end

	end
	if waypoint then 
		waypoint = waypoint:GetAbsOrigin()
--			thisEntity:MoveToPositionAggressive( waypoint:GetAbsOrigin() )
--			thisEntity:SetInitialGoalEntity(waypoint)
		AttackMove ( thisEntity, waypoint )
	else
		print("waypoint dont exist !!!")
	end
	return 1
	
end

function CastPointAbility( enemy )
	if enemy == nil then
		return
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = PointAbility:entindex(),
		Position = enemy:GetOrigin(),
		Queue = false,
	})

	return 0.5 
end

function CastTargetAbility( enemy )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = TargetAbility:entindex(),
		TargetIndex = enemy:entindex(),
		Queue = false,
	})

	return 0.5
end


