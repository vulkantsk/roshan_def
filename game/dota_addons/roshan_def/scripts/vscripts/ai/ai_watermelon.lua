--[[LinkLuaModifier("modifier_watermelon_passive", "ai/ai_watermelon", 0)
LinkLuaModifier("modifier_watermelon_no_cd", "ai/ai_watermelon", 0)

local ARENA_RADIUS = 2000

function Spawn(entityKeyValues)
	npc = thisEntity
	if not IsServer() then return end
	if npc == nil then return end

	JumpAbility = npc:FindAbilityByName("watermelon_jump")
	DivingAbility = npc:FindAbilityByName("watermelon_diving")
	MovingAbility = thisEntity:FindAbilityByName("watermelon_moving")
	TentacleAbility = npc:FindAbilityByName("watermelon_tentacle")
	TentacleDivingAbility = npc:FindAbilityByName("watermelon_tentacle_diving")
	WaveAbility = npc:FindAbilityByName("watermelon_wave")
	SuperWaveAbility = npc:FindAbilityByName("watermelon_wave_cast")

	JumpAbility:SetLevel(1)
	DivingAbility:SetLevel(1)
	MovingAbility:SetLevel(1)
	TentacleAbility:SetLevel(1)
	TentacleDivingAbility:SetLevel(1)
	WaveAbility:SetLevel(1)
	SuperWaveAbility:SetLevel(1)

	npc:SetContextThink("WatermelonThink", WatermelonThink, 1)
	npc:AddNewModifier(npc, nil, "modifier_watermelon_passive", nil)
end

function WatermelonThink()
	if not npc:IsAlive() then return -1 end
	if GameRules:IsGamePaused() then return 1 end

	print("Watermelon AI thinking")

	local boss_hp = npc:GetHealthPercent()
	local arena_center = Entities:FindByName(nil, "BOSS_WM_POS_5"):GetAbsOrigin()
	local enemies_on_arena = FindUnitsInRadius(npc:GetTeamNumber(), arena_center, nil, ARENA_RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 16 + 64 + 262144, 0, false)

	if #enemies_on_arena > 0 then
		if boss_hp < 100 then -- 1 стадия
			if JumpAbility:IsFullyCastable() then
				CastJumpAbility()
			end
			if WaveAbility:IsFullyCastable() then
				CastWaveAbility()
			end
			if TentacleAbility:IsFullyCastable() then
				CastTentacleAbility()
			end
		elseif boss_hp < 76 and boss_hp > 51 then -- 2 стадия
			if JumpAbility:IsFullyCastable() then
				CastJumpAbility(RandomInt(0, 1))
			end
			if WaveAbility:IsFullyCastable() then
				CastWaveAbility()
			end
			if TentacleAbility:IsFullyCastable() then
				CastTentacleAbility()
			end
			if DivingAbility:IsFullyCastable() then
				CastDivingAbility()
			end
			if SuperWaveAbility:IsFullyCastable() then
				CastSuperWaveAbility()
			end
		elseif boss_hp < 51 and boss_hp > 26 then -- 3 стадия
			if JumpAbility:IsFullyCastable() then
				CastJumpAbility(RandomInt(0, 1))
			end
			if WaveAbility:IsFullyCastable() then
				CastWaveAbility()
			end
			if TentacleAbility:IsFullyCastable() then
				CastTentacleAbility()
			end
			if DivingAbility:IsFullyCastable() then
				CastDivingAbility()
			end
			if SuperWaveAbility:IsFullyCastable() then
				CastSuperWaveAbility()
			end
			if TentacleDivingAbility:IsFullyCastable() then
				CastTentacleDivingAbility()
			end
			if MovingAbility:IsFullyCastable() then
				CastMovingAbility()
			end
		elseif boss_hp < 26 then -- 4 стадия
			if (JumpAbility and DivingAbility):IsFullyCastable() then
				CastAbsolute()
			end
		end
	end
	return 0.5
end

function CastJumpAbility(bOnPlace)
	if bOnPlace == 0 then
		bOnPlace = false
	else
		bOnPlace = true
	end
	local pos
	if bOnPlace then
		pos = npc:GetAbsOrigin()
		ExecuteOrderFromTable({
			UnitIndex = npc:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = JumpAbility:entindex(),
			Position = pos,
			Queue = false
		})
	else
		local farthest_enemy = FindUnitsInRadius(npc:GetTeamNumber(), npc:GetAbsOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_FARTHEST, false)
		for _, enemy in pairs(farthest_enemy) do
			pos = Entities:FindByClassnameNearest("info_target", enemy:GetAbsOrigin(), 800):GetAbsOrigin()
			break;
		end
		ExecuteOrderFromTable({
			UnitIndex = npc:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = JumpAbility:entindex(),
			Position = pos,
			Queue = false
		})
	end
	return 0.5
end

function CastWaveAbility()
	local closest_enemy = FindUnitsInRadius(npc:GetTeamNumber(), npc:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	for _, enemy in pairs(closest_enemy) do
		ExecuteOrderFromTable({
			UnitIndex = npc:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = WaveAbility:entindex(),
			Position = enemy:GetAbsOrigin(),
			Queue = false
		})
		break;
	end
	return 0.5
end

function CastTentacleAbility()
	local pos
	local closest_enemy = FindUnitsInRadius(npc:GetTeamNumber(), npc:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	for _, enemy in pairs(closest_enemy) do
		ExecuteOrderFromTable({
			UnitIndex = npc:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = TentacleAbility:entindex(),
			Position = Entities:FindByClassnameNearest("info_target", enemy:GetAbsOrigin(), 750),
			Queue = false
		})
		break;
	end
	return 0.5
end

function CastMovingAbility()
	ExecuteOrderFromTable({
		UnitIndex = npc:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = MovingAbility:entindex(),
		Queue = false
	})
	return 0.5
end

function CastDivingAbility()
	ExecuteOrderFromTable({
		UnitIndex = npc:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = DivingAbility:entindex(),
		Queue = false
	})
	return 0.5
end

function CastTentacleDivingAbility()
	npc:SetAbsOrigin(Entities:FindByName(nil, "BOSS_WM_POS_5"):GetAbsOrigin())
	ExecuteOrderFromTable({
		UnitIndex = npc:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = TentacleDivingAbility:entindex(),
		Queue = false
	})
	return 0.5
end

function CastSuperWaveAbility()
	ExecuteOrderFromTable({
		UnitIndex = npc:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = SuperWaveAbility:entindex(),
		Queue = false
	})
	return 0.5
end

function CastAbsolute()
	local farthest_enemy = FindUnitsInRadius(npc:GetTeamNumber(), npc:GetAbsOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_FARTHEST, false)
	for _, enemy in pairs(farthest_enemy) do
		pos = Entities:FindByClassnameNearest("info_target", enemy:GetAbsOrigin(), 800):GetAbsOrigin()
		break;
	end
	ExecuteOrderFromTable({
		UnitIndex = npc:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = JumpAbility:entindex(),
		Position = pos,
		Queue = false
	})
	JumpAbility:EndCooldown()
	DivingAbility:OnSpellStart(0.1, 0.1)
	DivingAbility:EndCooldown()
	return 1
end

modifier_watermelon_passive = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	} end
})

function modifier_watermelon_passive:OnTakeDamage(keys)
	if keys.unit == npc then
	end
end]]