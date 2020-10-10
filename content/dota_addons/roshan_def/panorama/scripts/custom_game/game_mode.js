"use strict";

/* Initialisation - runs when the element is created
=========================================================================*/
(function () {
	GameEvents.Subscribe( "Difficult_Vote_Update", DifficultVoteUpdate )
	InitializeUI()
	// Hides battlecuck crap
	var hit_test_blocker = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer");

	if (hit_test_blocker) {
		hit_test_blocker.hittest = false;
		hit_test_blocker.hittestchildren = false;
	}
})();

// Initializes the UI for the player with host privileges
function InitializeUI() {
	var player_info = Game.GetLocalPlayerInfo();
	if (!player_info) {
		$.Schedule(1, InitializeUI);
		return;
	} else {

		// Make the game options panel visible
		var game_options_panel = $('#game_options_container')
		game_options_panel.style.visibility = 'visible';

		// Animate it
		game_options_panel.style.opacity = 0.0;
		AnimatePanel(game_options_panel, { "transform": "translateX(250px);", "opacity": "1;" }, 1.0, "ease-out"); 
	}
	
	let amount = Game.GetAllPlayerIDs().length
	$.Msg('Player counts = ' + amount)
	$("#ToggleButtonContainer").visible = amount == 1
}

function OnPickingDonate(){ 
	$('#ToggleButtonBox').ToggleClass('Active')
	GameEvents.SendCustomGameEventToServer( "donate_state_update", {} );
}

// Locks the game mode
function SetGameOptions(diff)
{
	if ($('#ConfirmButton').visible)
	{
		for (var i = 0; i < 4; i++)
		{
			$('#ConfirmOptionsBtn'+i).RemoveClass("ActiveButton");
		}
		$('#ConfirmOptionsBtn'+diff).AddClass("ActiveButton");

	}
}

function ConfirmVote()
{
	for (var i = 0; i < 4; i++)
	{
		if ($('#ConfirmOptionsBtn'+i).BHasClass("ActiveButton"))
		{
			GameEvents.SendCustomGameEventToServer( "On_Difficult_Vote", { difficulty: i });
			$('#ConfirmButton').visible = false;
			//AnimatePanel($('#ConfirmButton'), { "opacity": "0;" }, 0.8);
			return;
		}
	}
}

function DifficultVoteUpdate(data)
{
	$.Msg(data);
	for ( var i in data ) {
		$('#ConfirmOptionsBtn'+data[i]).GetChild(1).text = Number.parseInt($('#ConfirmOptionsBtn'+data[i]).GetChild(1).text) + 1
	}
}