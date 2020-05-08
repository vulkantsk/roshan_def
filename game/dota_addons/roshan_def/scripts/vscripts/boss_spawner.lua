UNIT_INTERVAL_SPAWN = 0.5
BOSS_MARATHON_INTERVAL = 60
BOSS_MARATHON_MULTIPLIER = 0.4

if BossSpawner == nil then
	_G.BossSpawner = class({})
end

boss_music = {
	current_music = nil,
}

boss_list = {
--	[0]= {{boss_name="boss1", units={"npc_dota_boss"}, reward={100}, music=nil, marathon=false},
--{boss_name="boss2", units={"npc_dota_boss2","npc_dota_boss02","npc_dota_boss02"}, reward={100,50,50}, music="boss_theme2", marathon=true, marathon_mult=100}},
[1]= {{boss_name="abomination", units={"npc_dota_abomination_boss"}, reward={500}, music="akvalazi", marathon=true, marathon_mult=400},
{boss_name="evil_treant", units={"npc_dota_evil_treant"}, reward={500}, music=nil, marathon=true, marathon_mult=400}},
[2]= {{boss_name="fire_golem", units={"npc_dota_golem_boss"}, reward={1000}, music=nil, marathon=true, marathon_mult=300},
{boss_name="venom_dragon", units={"npc_dota_venom_dragon"}, reward={1000}, music=nil, marathon=true, marathon_mult=300}},
[3]= {{boss_name="witch", units={"npc_dota_dead_witch",["forest_dota_dead_ghost"]=3}, reward={1500}, music=nil, marathon=true, marathon_mult=200},
{boss_name="elite_squad", units={"npc_dota_dire_commander","npc_dota_dire_siege",["npc_dota_dire_soldier"]=2,["npc_dota_dire_mage"]=2}, reward={750,750}, music=nil, marathon=true, marathon_mult=200}},
[4]= {{boss_name="necronomicon", units={"npc_dota_necronomicon_warrior_boss","npc_dota_necronomicon_archer_boss"}, reward={1000,1000}, music="oingo_boingo_1", marathon=true, marathon_mult=150},
{boss_name="explosive_squad", units={["npc_explosive_squad_1"]= 6,["npc_explosive_squad_2"]= 6}, reward={["npc_explosive_squad_1"]=200,["npc_explosive_squad_2"]=200,}, music=nil, marathon=false, marathon_mult=150}},
[5]= {{boss_name="nyx", units={"npc_dota_nyx_boss"}, reward={3000}, music=nil, marathon=true, marathon_mult=100},
{boss_name="midas_acolyte", units={"npc_dota_midas_acolyte"}, reward={3000}, music=nil, marathon=true, marathon_mult=100}},
[6]= {{boss_name="doom", units={"npc_dota_doom_boss","npc_dota_doom_minion","npc_dota_doom_minion","npc_dota_doom_minion"}, reward={4000}, music="zoldik", marathon=true, marathon_mult=75},
{boss_name="thief", units={"npc_dota_thief"}, reward={4000}, music=nil, marathon=false, marathon_mult=100}},
[7]= {{boss_name="seeker", units={"npc_dota_bloodseeker_boss"}, reward={5000}, music=nil, marathon=true, marathon_mult=50}},
[8]= {{boss_name="sans", units={"npc_dota_sans"}, reward={7500}, music="sans_theme", marathon=nil, marathon_mult=200}},
[9]= {{boss_name="spectre", units={"npc_phantasm_1"}, reward={10000}, music=nil, marathon=nil, marathon_mult=200}},
[10]= {{boss_name="cursed_warriors", units={["npc_cursed_warrior"]=12}, reward={["npc_cursed_warrior"]=1000}, music="Sandopolis", marathon=true, marathon_mult=200}},
[11]= {{boss_name="plague_wagon", units={"npc_dota_plague_wagon"}, reward={10000}, music="krutoe_pike", marathon=false, marathon_mult=200}},

}

function BossSpawner:InitGameMode()

	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
--	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
end

function BossSpawner:OnGameRulesStateChange()
	local newState = GameRules:State_Get()
		if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			if GetMapName()=="roshdef_adventure" then
--				Spawn:NeutralSpawnerEvent()
			else
				BossSpawner:LineBossSpawner()
			end

		end
end
function BossSpawner:LineBossSpawner()

	  local spawn_interval = GameRules.line_boss_interval
	  local wave_number = 1

	  UpdateNettables()
	  Timers:CreateTimer(spawn_interval, function()
			local current_boss = boss_list[wave_number]
			if current_boss == nil then
				BossSpawner:FinalBossSpawner()
				Timers:CreateTimer(GameRules.line_boss_interval,function()
					BossSpawner:InitBossMarathon()
 				end)
		    	UpdateNettables()
				return
			end
			BossSpawner:SpawnBoss(wave_number) 
	     	UpdateNettables()
	     	wave_number = wave_number + 1
			return spawn_interval
	     end)
	
end

function BossSpawner:SpawnBoss(index)
	local current_boss = boss_list[index]
	if current_boss == nil then
		return
	end
	local point = Entities:FindByName( nil, "dmpoint2"):GetAbsOrigin() 
	local waypoint = Entities:FindByName( nil, "d_waypoint1") 
	--      local point1 = Entities:FindByName( nil, "drpoint2"):GetAbsOrigin() 
	if Spawn.DireSpawner == 0 then 
			point = Entities:FindByName( nil, "dmpoint1"):GetAbsOrigin()
	--      		point1 = Entities:FindByName( nil, "drpoint1"):GetAbsOrigin()
			waypoint = Entities:FindByName( nil, "d_waypoint11") 
	end

	local boss = current_boss[RandomInt(1, #current_boss)]
	local boss_name = boss.boss_name
	local units = boss.units
	local reward = boss.reward
	local music = boss.music
	print(boss_name)
	print(units[1])
	print(reward[1])
	print(music)

	if music then
		if boss_music.current_music then
			Sounds:RemoveGlobalLoopingSound(boss_music.current_music)
--					print("current_music = "..boss_music.current_music)
		end
		print("current_music = "..music)
		boss_music.current_music = music
		boss_music[music] = 0
		Sounds:CreateGlobalLoopingSound(music)
	else
		Sounds:CreateGlobalSound("roshan_def.boss")
	end

	GameRules:SendCustomMessage("#Game_notification_boss_spawn_"..boss_name,0,0)
	local unit_total = 0

	for key, value in pairs (units) do
		local unit_name
		local unit_reward = reward[key]
		local unit_count = 1
		if type(key) == "string" then
			unit_count = value
			unit_name = key
		else
			unit_name = value
		end

		for i=1, unit_count do
			unit_total = unit_total + 1
			Timers:CreateTimer(unit_total*UNIT_INTERVAL_SPAWN,function()
				local unit = CreateUnitByName( unit_name , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
				unit:SetInitialGoalEntity( waypoint )

				if unit_reward then
					unit.reward = unit_reward
				end

				if music then
					boss_music[music] = boss_music[music] + 1
					unit.music = music
				end 
			end)
		end
	end 
end

function BossSpawner:FinalBossSpawner()
	local spawn_interval = 10
	--	  UpdateNettables(10)
	local wave_number = 1
	local point = Entities:FindByName( nil, "dmpoint2"):GetAbsOrigin() 
	local waypoint = Entities:FindByName( nil, "d_waypoint1") 
	GameRules:SendCustomMessage("#Game_notification_boss_final",0,0)

	Timers:CreateTimer(0, function()
		local current_boss = boss_list[wave_number]
		if current_boss == nil then
			return
		end
		local boss = current_boss[RandomInt(1, #current_boss)]
		local boss_name = boss.boss_name
		local units = boss.units
		local reward = boss.reward
		local music = boss.music
--		print(boss_name)
--		print(units[1])
--		print(reward[1])
--		print(music)
		local unit_total = 0

		for key, value in pairs (units) do
			local unit_name
			local unit_reward = reward[key]
			local unit_count = 1
			if type(key) == "string" then
				unit_count = value
				unit_name = key
			else
				unit_name = value
			end

			for i=1, unit_count do
				unit_total = unit_total + 1
				Timers:CreateTimer(unit_total*UNIT_INTERVAL_SPAWN,function()
					local unit = CreateUnitByName( unit_name , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
					unit:SetInitialGoalEntity( waypoint )

					if unit_reward then
						unit.reward = unit_reward
					end
				end)
			end
		end  

	 	wave_number = wave_number + 1
		return spawn_interval
	 end)	
end

function BossSpawner:InitBossMarathon()
	marathon_list = {}

	for _, current_boss in pairs(boss_list) do
		for _, boss in pairs(current_boss) do
			if boss.marathon then
				table.insert(marathon_list, boss)
			end
		end
	end

	if boss_music.current_music then
		Sounds:RemoveGlobalLoopingSound(boss_music.current_music)
--		print("current_music = "..boss_music.current_music)
	end
	boss_music.current_music = "satan_bal"
	GameRules:SendCustomMessage("#Game_notification_infinite_maraphon",0,0)
	Sounds:CreateGlobalLoopingSound(boss_music.current_music)

	local point = Entities:FindByName( nil, "dmpoint2"):GetAbsOrigin() 
	local waypoint = Entities:FindByName( nil, "d_waypoint1") 
	local spawn_interval = BOSS_MARATHON_INTERVAL
	local current_wave = 0
	local marathon_exp = BOSS_MARATHON_MULTIPLIER

	Timers:CreateTimer(0,function()
		local boss =marathon_list[RandomInt(1, #marathon_list)]
--		Sounds:CreateGlobalSound("roshan_def.boss")
		local boss_name = boss.boss_name
		local units = boss.units
		local reward = boss.reward
		local marathon_mult = boss.marathon_mult
		local unit_total = 0

		for key, value in pairs (units) do
			local unit_name
			local unit_reward = reward[key]
			local unit_count = 1
			if type(key) == "string" then
				unit_count = value
				unit_name = key
			else
				unit_name = value
			end

			for i=1, unit_count do
				unit_total = unit_total + 1
				Timers:CreateTimer(unit_total*UNIT_INTERVAL_SPAWN,function()
					local unit = CreateUnitByName( unit_name , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
					unit:SetInitialGoalEntity( waypoint )
					Spawn:Upgrade4(unit, marathon_mult)
					Spawn:Upgrade4(unit, 1 + marathon_exp*current_wave)

					if unit_reward then
						unit.reward = unit_reward
					end
				end)
			end
		end		 

		current_wave = current_wave + 1
	    UpdateNettables(spawn_interval)
     	return spawn_interval		
	end)
end

function BossSpawner:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)

	if unit.reward then
		GiveGoldPlayers(unit.reward)
	end

	if unit.music then
		local music = unit.music
		boss_music[music] = boss_music[music] - 1
		if boss_music[music] == 0 and boss_music.current_music == music then
			Sounds:RemoveGlobalLoopingSound(music)
		end
	end
end

BossSpawner:InitGameMode()