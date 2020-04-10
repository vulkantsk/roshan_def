"use strict";

/* Initialisation - runs when the element is created
=========================================================================*/
(function () {
	InitializeUI()
	// Hides battlecuck crap
	var hit_test_blocker = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer");

	if (hit_test_blocker) {
		hit_test_blocker.hittest = false;
		hit_test_blocker.hittestchildren = false;
	}
})();

function OnPickingDonate(){ 
	$('#ToggleButtonBox').ToggleClass('Active')
	GameEvents.SendCustomGameEventToServer( "donate_state_update", {} );
}

// Initializes the UI for the player with host privileges
function InitializeUI() {
	var is_host = CheckForHostPrivileges();
	if (is_host === undefined) {
		$.Schedule(1, InitializeUI);
		return;
	} else if (is_host) {

		// Make the game options panel visible
		var game_options_panel = $('#game_options_container')
		game_options_panel.style.visibility = 'visible';

		// Animate it
		game_options_panel.style.opacity = 0.0;
		AnimatePanel(game_options_panel, { "transform": "translateX(250px);", "opacity": "1;" }, 1.0, "ease-out"); 

		// Update other elements according to the current map
		var map_info = Game.GetMapInfo();
		/*
		if (map_info.map_display_name == "template_map") {
			$('#QuickOptionsPanel').style.visibility = 'collapse';
			$('#HeroPowerOptionsPanel').style.visibility = 'collapse';
			$('#CreepPowerOptionsPanel').style.visibility = 'collapse';
			$('#TowerPowerOptionsPanel').style.visibility = 'collapse';
			$('#RespawnTimeOptionsPanel').style.visibility = 'collapse';
			$('#TowerUpgradesToggle').style.visibility = 'collapse';
			$('#HeroPickRulePanel').style.visibility = 'collapse';
			$('#AllPickToggle').style.visibility = 'collapse';
			$('#AllRandomToggle').style.visibility = 'collapse';
			$('#AllRandomSameHeroToggle').style.visibility = 'collapse';
		} else if (map_info.map_display_name == "imba_10v10" || map_info.map_display_name == "imba_12v12") {
			$('#game_options_game_mode_title').text = $.Localize( "#imba_gamemode_name_10v10" );
			$('#QuickOptionsPanel').style.visibility = 'collapse';
			$('#HeroPowerOptionsPanel').style.visibility = 'collapse';
			$('#CreepPowerOptionsPanel').style.visibility = 'collapse';
			$('#TowerPowerOptionsPanel').style.visibility = 'collapse';
			$('#RespawnTimeOptionsPanel').style.visibility = 'collapse';
			$('#TowerUpgradesToggle').style.visibility = 'collapse';
			$('#HeroPickRulePanel').style.visibility = 'collapse';
			$('#AllPickToggle').style.visibility = 'collapse';
			$('#AllRandomToggle').style.visibility = 'collapse';
			$('#AllRandomSameHeroToggle').style.visibility = 'collapse';
		} else if (map_info.map_display_name == "imba_custom") {
			$('#TowerUpgradesToggle').SetSelected(true);
			$('#FranticToggle').style.visibility = 'visible';
		} else if (map_info.map_display_name == "imba_custom_10v10") {
			$('#TowerUpgradesToggle').SetSelected(true);
			$('#FranticToggle').style.visibility = 'visible';
		} else if (map_info.map_display_name == "imba_arena") {
			$('#game_options_game_mode_title').text = $.Localize( "#imba_gamemode_name_arena_mode" );
			$('#KillsToEndOptionsPanel').style.visibility = 'visible';
			$('#QuickOptionsPanel').style.visibility = 'collapse';
			$('#HeroPowerOptionsPanel').style.visibility = 'collapse';
			$('#CreepPowerOptionsPanel').style.visibility = 'collapse';
			$('#TowerPowerOptionsPanel').style.visibility = 'collapse';
			$('#RespawnTimeOptionsPanel').style.visibility = 'collapse';
			$('#TowerUpgradesToggle').style.visibility = 'collapse';
			$('#HeroPickRulePanel').style.visibility = 'collapse';
			$('#AllPickToggle').style.visibility = 'collapse';
			$('#AllRandomToggle').style.visibility = 'collapse';
			$('#AllRandomSameHeroToggle').style.visibility = 'collapse';
		} else if (map_info.map_display_name == "imba_diretide") {
			$('#game_options_container').style.visibility = 'collapse';
			$('#CustomBg').style.backgroundImage = 'url("file://{images}/custom_game/loading_screen/diretide.jpg")';
		}
		*/
	}
		let amount = Game.GetAllPlayerIDs().length
		$.Msg('Player counts = ' + amount)
		$("#ToggleButtonContainer").visible = amount == 1
}

// Checks if the local player has local privileges
function CheckForHostPrivileges() {
	var player_info = Game.GetLocalPlayerInfo();
	if ( !player_info ) {
		return undefined;
	} else {
		return player_info.player_has_host_privileges;
	}
}

/* Sets all options to Normal mode
function SetQuickOptionsNormal() {

	// Disables upgradable towers in standard and 10v10
	var map_info = Game.GetMapInfo();
	if (map_info.map_display_name == "imba_standard" || map_info.map_display_name == "imba_10v10" || map_info.map_display_name == "imba_12v12") {
		$('#TowerUpgradesToggle').SetSelected(false);
	} 

	// Sets everything else to normal options
	$('#GoldOptionsDropdown').SetSelected('GoldOption1');
	$('#ExpOptionsDropdown').SetSelected('ExpOption1');
	$('#CreepPowerOptionsDropdown').SetSelected('CreepPowerOption1');
	$('#TowerPowerOptionsDropdown').SetSelected('TowerPowerOption1');
	$('#RespawnTimeOptionsDropdown').SetSelected('RespawnTimeOption1');
	$('#HeroPowerDropdown').SetSelected('HeroPower1');
}

// Sets all options to Hyper mode
function SetQuickOptionsHigh() {

	// Enables upgradable towers in standard and 10v10
	var map_info = Game.GetMapInfo();
	if (map_info.map_display_name == "imba_standard" || map_info.map_display_name == "imba_10v10" || map_info.map_display_name == "imba_12v12") {
		$('#TowerUpgradesToggle').SetSelected(true);
	} 

	// Sets everything else to high options
	$('#GoldOptionsDropdown').SetSelected('GoldOption2');
	$('#ExpOptionsDropdown').SetSelected('ExpOption2');
	$('#CreepPowerOptionsDropdown').SetSelected('CreepPowerOption2');
	$('#TowerPowerOptionsDropdown').SetSelected('TowerPowerOption2');
	$('#RespawnTimeOptionsDropdown').SetSelected('RespawnTimeOption2');
	$('#HeroPowerDropdown').SetSelected('HeroPower2');
}
*/
// Locks the game mode
function SetGameOptions()
{
/*	GameEvents.SendCustomGameEventToServer( "set_game_mode", {
		"is_host": CheckForHostPrivileges(),
		"modes": {
			"all_pick": $('#AllPickToggle').checked,
			"all_random": $('#AllRandomToggle').checked,
			"all_random_same_hero": $('#AllRandomSameHeroToggle').checked,
			"frantic_mode": $('#FranticToggle').checked,
			"tower_upgrades": $('#TowerUpgradesToggle').checked,
			"bounty_multiplier": $('#GoldOptionsDropdown').GetSelected().id,
			"exp_multiplier": $('#ExpOptionsDropdown').GetSelected().id,
			"creep_power": $('#CreepPowerOptionsDropdown').GetSelected().id,
			"tower_power": $('#TowerPowerOptionsDropdown').GetSelected().id,
			"respawn_reduction": $('#RespawnTimeOptionsDropdown').GetSelected().id,
			"hero_power": $('#HeroPowerDropdown').GetSelected().id,
			"kills_to_end": $('#KillsToEndOptionsDropdown').GetSelected().id,
            "hero_pick_rule" : $('#HeroPickRuleDropdown').GetSelected().id,
		}
	});
*/
	GameEvents.SendCustomGameEventToServer( "On_Difficult_Chosen", { "is_host": CheckForHostPrivileges(), difficulty: 0 })

	AnimatePanel($('#game_options_container'), { "transform": "translateX(-150px);", "opacity": "0;" }, 0.8);
}

function SetGameOptions1()
{

	GameEvents.SendCustomGameEventToServer( "On_Difficult_Chosen", { "is_host": CheckForHostPrivileges(), difficulty: 1 })

	AnimatePanel($('#game_options_container'), { "transform": "translateX(-150px);", "opacity": "0;" }, 0.8);
}

function SetGameOptions2()
{

	GameEvents.SendCustomGameEventToServer( "On_Difficult_Chosen", { "is_host": CheckForHostPrivileges(), difficulty: 2 })

	AnimatePanel($('#game_options_container'), { "transform": "translateX(-150px);", "opacity": "0;" }, 0.8);
}

function SetGameOptions3()
{

	GameEvents.SendCustomGameEventToServer( "On_Difficult_Chosen", { "is_host": CheckForHostPrivileges(), difficulty: 3 })

	AnimatePanel($('#game_options_container'), { "transform": "translateX(-150px);", "opacity": "0;" }, 0.8);
}

// Shows/hides the community panel
function ShowCommunityButton() {
	var community_panel = $.GetContextPanel().FindChildTraverse("CommunityPanel");
	
	community_panel.ToggleClass('invisible')
}
