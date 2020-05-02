require('libraries')
require('Spawn')
require('boss_spawner')
require('libraries/buildinghelper')

require('barebones')
require('abilities/basic')
require('modules/index')

function Precache( context )
	-- NOTE: IT IS RECOMMENDED TO USE A MINIMAL AMOUNT OF LUA PRECACHING, AND A MAXIMAL AMOUNT OF DATADRIVEN PRECACHING.
	-- Precaching guide: https://moddota.com/forums/discussion/119/precache-fixing-and-avoiding-issues

	--[[
	This function is used to precache resources/units/items/abilities that will be needed
	for sure in your game and that cannot or should not be precached asynchronously or 
	after the game loads.

	See GameMode:PostLoadPrecache() in barebones.lua for more information
	]]

	print("[BAREBONES] Performing pre-load precache")

	-- Particles can be precached individually or by folder
	-- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
	PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context )
	PrecacheResource("soundfile", "soundevents/imba_item_soundevents.vsndevts", context )
	PrecacheResource("soundfile", "soundevents/game_sounds_winter_2018.vsndevts", context )
	PrecacheResource("soundfile", "soundevents/game_sounds_dungeon_enemies.vsndevts", context )

	-- Radiant Hulk (Behemoth)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_ambient.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_ambient_energy.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_ambient_flakes.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_swipe.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_swipe_glow.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_swipe_left.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_radiant_hulk_swipe_right.vpcf", context)    

	-- Dire Hulk (Behemoth)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_ambient_core.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_flames.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_rays.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_swipe.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_swipe_glow.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_swipe_left.vpcf", context)
	PrecacheResource("particle", "particles/creeps/lane_creeps/creep_dire_hulk_swipe_right.vpcf", context)    
	PrecacheResource("particle", "particles/rainbow.vpcf", context)    
	PrecacheResource("particle", "particles/econ/events/ti7/ti7_hero_effect.vpcf", context)    
	PrecacheResource("particle", "particles/dire_fx/bad_ancient_ambient.vpcf", context)    
	PrecacheResource("particle", "particles/econ/courier/courier_trail_winter_2012/courier_trail_winter_2012_snow.vpcf", context)    

	PrecacheResource("particle_folder", "particles/units/heroes/heroes_underlord/", context)
	PrecacheResource("particle_folder", "particles/status_fx/", context)
	PrecacheResource("particle_folder", "particles/item", context)
	PrecacheResource("particle_folder", "particles/items_fx", context)
	PrecacheResource("particle_folder", "particles/items2_fx", context)
	PrecacheResource("particle_folder", "particles/items3_fx", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_chaos_knight", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_abyssal_underlord", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_faceless_void", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_phoenix", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_phantom_assassin", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_alchemist", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_gyrocopter", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_zuus", context)
	PrecacheResource("particle_folder", "particles/econ/items/axe/ti9_jungle_axe/", context)

	PrecacheUnitByNameSync("npc_dota_dire1", context)
	-- Models can also be precached by folder or individually
	-- PrecacheModel should generally used over PrecacheResource for individual models
	PrecacheResource("model_folder", "particles/heroes/antimage", context)
	PrecacheResource("model_folder", "models/items/axe/ti9_jungle_axe/", context)
	PrecacheUnitByNameSync("example_unit_1", context)

	-- Sounds can precached here like anything else

	PrecacheUnitByNameSync("npc_dota_dire1", context)
	PrecacheUnitByNameSync("npc_dota_dire2", context)
	PrecacheUnitByNameSync("npc_dota_dire3", context)
	PrecacheUnitByNameSync("npc_dota_dire4", context)
	PrecacheUnitByNameSync("npc_dota_dire5", context)
	PrecacheUnitByNameSync("npc_dota_direr1", context)
	PrecacheUnitByNameSync("npc_dota_direr2", context)
	PrecacheUnitByNameSync("npc_dota_direr3", context)
	PrecacheUnitByNameSync("npc_dota_direr4", context)
	PrecacheUnitByNameSync("npc_dota_dguard1", context)
	PrecacheUnitByNameSync("npc_dota_dguard2", context)
	PrecacheUnitByNameSync("npc_dota_nguard1", context)
	PrecacheUnitByNameSync("npc_dota_nguard2", context)
	PrecacheUnitByNameSync("npc_dota_hero_meepo", context)

 --   PrecacheItemByNameSync( "item_tombstone", context )
 
 --   PrecacheResource( "model", "models/gameplay/attrib_tome_int.vmdl", context  )
	
--    PrecacheResource( "particle", "particles/test_particle/dungeon_generic_blast_ovr_pre.vpcf", context  )
 
--    PrecacheResource( "particle_folder", "particles/units/heroes/hero_winter_wyvern", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_pudge", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_sven", context )
 --Sounds
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_shadow_demon.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_skywrath_mage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_dark_willow.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_terrorblade.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_lich.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_nevermore.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_undying.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_necrolyte.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_skeleton_king.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skeleton_king.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_announcer_dlc_glados.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_announcer_dlc_gaben_killing_spree.vsndevts", context )
 
 	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_terrorblade.vsndevts", context )
 	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_spectre.vsndevts", context )
 	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_obsidian_destroyer.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_outworld_destroyer.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_warlock_golem.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_dazzle.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_broodmother.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sven.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_treant.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_slark.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_naga_siren.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_viper.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_pudge.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_shredder.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_bloodseeker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_omniknight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_roshan_frostivus.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_morphling.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tidehunter.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skeletonking.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_gyrocopter.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_rattletrap.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_alchemist.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_sniper.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_phantom_assassin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_drowranger.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_faceless_void.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_void_spirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_arc_warden.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_arc_warden.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_puck.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_puck.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_templar_assassin.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_antimage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_abyssal_underlord.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_stormspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_dragon_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_chaos_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_juggernaut.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_axe.vsndevts", context )

end
-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
	GameRules.GameMode:AnitGameMode()
	Spawn:InitGameMode()
	request:Init()

	Convars:SetBool("sv_cheats", true)
end

function GameMode:AnitGameMode()
	if GetMapName() == "roshdef_event" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	else
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	end

	GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 2400 ) 
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed( 50 )
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled( true ) 
--	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled( true )
	GameRules:GetGameModeEntity():SetBuybackEnabled( true )
	PlayerResource:SetCustomBuybackCost(0,1000)
--[[	
	local GM = GameRules:GetGameModeEntity()
	GM:SetCustomGameForceHero("npc_dota_hero_puck")
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)
]]
	for i=0,4 do
		
--			PlayerResource:SetCustomBuybackCooldown(i, 60)		
			PlayerResource:SetCustomBuybackCost(i, 0)
	end
end