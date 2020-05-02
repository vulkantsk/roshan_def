--LinkLuaModifier( "modifier_fow_vision", "modifiers/modifier_fow_vision", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	TargetAbility = thisEntity:FindAbilityByName( "explosive_squad_boom" )

	thisEntity:SetContextThink( "ExplosionSquad", ExplosionSquad, 1 )
end

function ExplosionSquad()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end
	
	if GameRules:IsGamePaused() == true then
		return 1
	end

	local roshan = Entities:FindByName( nil, "roshan")
	if roshan then		
		if TargetAbility ~= nil and TargetAbility:IsFullyCastable() then
			return CastTargetAbility( roshan )
		end	
	end

	return 1
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




