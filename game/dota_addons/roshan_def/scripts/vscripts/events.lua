function GameMode:OnListenEvents()
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPlayerPickHero'), self)
	ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(GameMode, 'OnTeamKillCredit'), self)

	-- Listeners - Event Hooks
	-- All of these events can potentially be fired by the game, though only the uncommented ones have had
	-- Functions supplied for them.
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameMode, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(GameMode, 'OnAbilityChannelFinished'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(GameMode, 'OnPlayerLearnedAbility'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, 'OnConnectFull'), self)
--	ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameMode, 'OnDisconnect'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'OnPlayerReconnect'), self)
--	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(GameMode, 'OnItemPurchased'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameMode, 'OnItemPickedUp'), self)
--	ListenToGameEvent('last_hit', Dynamic_Wrap(GameMode, 'OnLastHit'), self)
--	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(GameMode, 'OnNonPlayerUsedAbility'), self)
--	ListenToGameEvent('player_changename', Dynamic_Wrap(GameMode, 'OnPlayerChangedName'), self)
--	ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(GameMode, 'OnRuneActivated'), self)
--	ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(GameMode, 'OnPlayerTakeTowerDamage'), self)
--	ListenToGameEvent('tree_cut', Dynamic_Wrap(GameMode, 'OnTreeCut'), self)
--	ListenToGameEvent('entity_hurt', Dynamic_Wrap(GameMode, 'OnEntityHurt'), self)
--	ListenToGameEvent('player_connect', Dynamic_Wrap(GameMode, 'PlayerConnect'), self)
end

-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function GameMode:PlayerConnect(keys)
	print('[BAREBONES] PlayerConnect')
	DeepPrintTable(keys)

	if keys.bot == 1 then
		-- This user is a Bot, so add it to the bots table
		self.vBots[keys.userid] = 1
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	print ('[BAREBONES] OnConnectFull')
	DeepPrintTable(keys)
	GameMode:CaptureGameMode()

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	-- Update the user ID table with this user
	self.vUserIds[keys.userid] = ply

	-- Update the Steam ID table
	self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If the player is a broadcaster flag it in the Broadcasters table
	if PlayerResource:IsBroadcaster(playerID) then
		self.vBroadcasters[keys.userid] = 1
		return
	end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
	--print("[BAREBONES] Entity Hurt")
	--DeepPrintTable(keys)
--	local entCause = EntIndexToHScript(keys.entindex_attacker)
--	local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
	print ( '[BAREBONES] OnItemPurchased' )
	DeepPrintTable(keys)

--	local heroEntity = EntIndexToHScript()
	local unit_index = keys.HeroEntityIndex or keys.UnitEntityIndex
	local hero = EntIndexToHScript(unit_index):GetPlayerOwner()
	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = keys.PlayerID
	local itemname = keys.itemname
	
	--r = RandomInt(200, 400)
	if itemname == "item_chicken_coin" then
		local r = 300
		PlayerResource:ModifyGold( player, r, true, 0 )
		SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, r, nil )
		UTIL_Remove( itemEntity ) -- otherwise it pollutes the player inventory
		--print("Bag of gold picked up")
	elseif itemname == "item_event_gold_bag" then
		GiveGoldPlayers(10)
		UTIL_Remove( itemEntity ) -- otherwise it pollutes the player inventory
	elseif itemname == "item_event_gold_coin" then
		GiveGoldPlayers(100)
		UTIL_Remove( itemEntity ) -- otherwise it pollutes the player inventory
	end
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
	print ( '[BAREBONES] OnPlayerReconnect' )
	DeepPrintTable(keys)
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
	print ( '[BAREBONES] OnItemPurchased' )
	DeepPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname

	-- The cost of the item purchased
	local itemcost = keys.itemcost

end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
	print('[BAREBONES] AbilityUsed')
	DeepPrintTable(keys)

	local player = EntIndexToHScript(keys.PlayerID)
	local abilityname = keys.abilityname
	local caster = EntIndexToHScript(keys.caster_entindex)
	
	
	if GetMapName() == "roshdef_turbo" then
		if abilityname == "item_ultra_boots" or abilityname == "item_travel_boots_2" or abilityname == "item_travel_boots"or abilityname == "item_tpscroll" then
			for i=0,8 do
				local item = caster:GetItemInSlot( i )
				local item_name = ""
				if item then item_name = item:GetAbilityName() end
--				print ("item = "..item_name)
				
				if item and item_name == abilityname then 
					Timers:CreateTimer(0.01,function()
--						local cooldown = item:GetCooldownTimeRemaining()/2
						local cooldown = item:GetCooldownTime()/2
						item:EndCooldown()
						item:StartCooldown(cooldown)
					end)
				end 			
			end
		end
	end

end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
	print('[BAREBONES] OnNonPlayerUsedAbility')
	DeepPrintTable(keys)

	local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
	print('[BAREBONES] OnPlayerChangedName')
	DeepPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
	print ('[BAREBONES] OnPlayerLearnedAbility')
	DeepPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
	print ('[BAREBONES] OnAbilityChannelFinished')
	DeepPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1

end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
	print ('[BAREBONES] OnPlayerLevelUp')
	DeepPrintTable(keys)

--	local player = EntIndexToHScript(keys.player)
--	local hero = EntIndexToHScript(keys.hero_entindex)
	local hero = PlayerResource:GetSelectedHeroEntity(keys.player_id)
	local level = keys.level
	local ability_point = hero:GetAbilityPoints()
	print(level)

	if level >= 30 then
		hero:SetAbilityPoints(ability_point + 1)
	end
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	print ('[BAREBONES] OnLastHit')
	DeepPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	print ('[BAREBONES] OnTreeCut')
	DeepPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
	print ('[BAREBONES] OnRuneActivated')
	DeepPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
	print ('[BAREBONES] OnPlayerTakeTowerDamage')
	DeepPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
	print ('[BAREBONES] OnPlayerPickHero')
	DeepPrintTable(keys)

	local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	print ('[BAREBONES] OnTeamKillCredit')
	DeepPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
--	print( '[BAREBONES] OnEntityKilled Called' )
--	DeepPrintTable( keys )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil
	local team= killedUnit:GetTeam()
	
	if killedUnit:IsRealHero() and killedUnit:IsReincarnating() == false then
		killedUnit:SetTimeUntilRespawn( HERO_RESPAWN_TIME )
	end
	
	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- Put code here to handle when an entity gets killed
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
--	print("[BAREBONES] NPC Spawned")
--	DeepPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()
	
	if npc:IsRealHero() and npc.bFirstSpawned == nil then
--		GameMode:OnHeroInGame(npc)		
		npc.bFirstSpawned = true
		local playerID = npc:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)

		if FirstSpawned == nil then
			FirstSpawned = {}
		end
		
		if not FirstSpawned[playerID] then
			if name == "npc_dota_hero_wisp" then
				for i=0,8 do
					local item = npc:GetItemInSlot(i)
					if item then
						npc:RemoveItem(item)
					end
					npc:AddItemByName("item_wisp")
				end
			elseif name == "npc_dota_hero_keeper_of_the_light" then
				for i=2,6 do
					local item = npc:GetItemInSlot(i-1)
					if item then
						npc:RemoveItem(item)
					end
					npc:AddItemByName("item_epic_tower_closed_slot_"..i)
				end
			end

			FirstSpawned[playerID] = true
			while npc:GetLevel() < HERO_START_LEVEL do
				npc:AddExperience(100, 0, true, true)
			end
		end
	end	
	if npc:IsTempestDouble() or npc:IsIllusion() then
		local owner = npc:GetPlayerOwner():GetAssignedHero()
		npc:SetTeam(owner:GetTeam())
		for _, modifier in pairs( owner:FindAllModifiers() ) do
			local stacks = modifier:GetStackCount()
			local modifier_name = modifier:GetName()
			if stacks > 0 then
				local modifier = npc:AddNewModifier(owner, nil, modifier_name, {})
				modifier:SetStackCount(stacks)
			end
		end
	end
end



function GameMode:PostLoadPrecache()
	print("[BAREBONES] Performing Post-Load precache")

end

function GameMode:OnFirstPlayerLoaded()
	print("[BAREBONES] First Player has loaded")
end

function GameMode:OnAllPlayersLoaded()
	print("[BAREBONES] All Players have loaded into the game")
end

function GameMode:OnHeroInGame(hero)
	print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

	-- Store a reference to the player handle inside this hero handle.
	hero.player = PlayerResource:GetPlayer(hero:GetPlayerID())
	-- Store the player's name inside this hero handle.
	hero.playerName = PlayerResource:GetPlayerName(hero:GetPlayerID())
	-- Store this hero handle in this table.
	table.insert(self.vPlayers, hero)

	-- This line for example will set the starting gold of every hero to 500 unreliable gold


	-- These lines will create an item and add it to the player, effectively ensuring they start with the item
	--local item = CreateItem("item_example_item", hero, hero)
	--hero:AddItem(item)
end

function GameMode:OnGameInProgress()
	print("[BAREBONES] The game has officially begun")

	Timers:CreateTimer(60, function() -- Start this timer 30 game-time seconds later
		GiveExperiencePlayers( 1 )
		return 60.0 -- Rerun this timer every 30 game-time seconds
	end)
end

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
	print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	DeepPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end

-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
	print("[BAREBONES] GameRules State Changed")
	DeepPrintTable(keys)

	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_INIT then
		Timers:RemoveTimer("alljointimer")
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		local et = 6
		if self.bSeenWaitForPlayers then
			et = .01
		end
		Timers:CreateTimer("alljointimer", {
			useGameTime = true,
			endTime = et,
			callback = function()
				if PlayerResource:HaveAllPlayersJoined() then
					GameMode:PostLoadPrecache()
					GameMode:OnAllPlayersLoaded()
					return
				end
				return 1
			end})
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameMode:OnGameInProgress()
	end
end

function GameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	r = 300
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		--print("Bag of gold picked up")
		PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	elseif event.itemname == "item_treasure_chest" then
		--print("Special Item Picked Up")
		DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Stop", "0", 0, self, self )
		COverthrowGameMode:SpecialItemAdd( event )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end