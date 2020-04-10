tester.config = {
	ACCES = {
		ALL = 1, -- all acces panel
		ONLY_CHEATS = 2, -- only developer and cheat mode
	},
	biomes = {
		['Spider Forest'] = {
			npc_dota_spider_0 = true,
			npc_dota_spider_1 = true,
			npc_dota_spider_2 = true,
			npc_dota_spider_3 = true,
			npc_dota_spider_4 = true,
			npc_dota_spider_boss_1 = true,
			npc_dota_spider_boss_2 = true,
			npc_dota_spider_boss_3 = true,
		},
		['Radiant Forest'] = {
			npc_dota_radiant_forest_1 = true,
			npc_dota_radiant_forest_2 = true,
			npc_dota_radiant_forest_3 = true,
			npc_dota_radiant_forest_4 = true,
			npc_dota_boss_forest_1 = true,
			npc_dota_boss_forest_2 = true,
			npc_dota_boss_forest_3 = true,
		},
		['Alliance Forest'] = {
			npc_dota_alliance_1 = true,
			npc_dota_alliance_2 = true,
			npc_dota_alliance_3 = true,
			npc_dota_alliance_4 = true,
			npc_dota_alliance_5 = true,
			npc_dota_alliance_6 = true,
			npc_dota_alliance_7 = true,
			npc_dota_alliance_8 = true,
			npc_dota_boss_fire_1 = true,
			npc_dota_boss_fire_2 = true,
			npc_dota_boss_fire_3 = true,
		},
		['Dark Forest'] = {
			npc_dota_dire_forest_1 = true,
			npc_dota_dire_forest_2 = true,
			npc_dota_dire_forest_3 = true,
			npc_dota_dire_forest_4 = true,
			npc_dota_boss_vampire_1 = true,
			npc_dota_boss_vampire_2 = true,
			npc_dota_boss_vampire_3 = true,
		},
		['Naga Forest'] = {
			npc_dota_naga_1 = true,
			npc_dota_naga_2 = true,
			npc_dota_naga_3 = true,
			npc_dota_naga_4 = true,
			npc_dota_naga_5 = true,
			npc_dota_naga_6 = true,
			npc_dota_naga_7 = true,
			npc_dota_naga_8 = true,
			npc_dota_naga_boss_3 = true,
			npc_dota_naga_boss_2 = true,
			npc_dota_naga_boss_1 = true,
			npc_dota_boss_water_1 = true,
			npc_dota_boss_water_2 = true,
			npc_dota_boss_water_3 = true,
		},
		['Neutral Bosses'] = {
			Spectre_boss = true,
		}
	}
}

tester.items_remove = {
	-- example
	item = true, -- delete item by name 'item' 
	item_blink = true,
	item_chicken_coin = true,
} 
tester.creep_remove = {
	-- example
	creep = true, -- delete creep by name 'creep' 
} 

tester.items_match = {
	-- find str and remove 
	'closed_slot',
	'dummy',
	'recipe',
	'rune',
	'bag_of_gold',
	'bonus_health',
	'test',
	'river_painter',
}
tester.creep_match = {
	'ritual',
	'test',
} 