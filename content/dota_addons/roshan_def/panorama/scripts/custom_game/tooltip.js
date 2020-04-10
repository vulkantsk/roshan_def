function OnLoadingCreepModel(){
	var creepname = $.GetContextPanel().GetAttributeString("creepname", "npc_dota_hero_target_dummy")
	$.GetContextPanel().SetDialogVariable('creep_name', $.Localize(creepname).toUpperCase())
	$('#ScenePanelContainer_tooltip').RemoveAndDeleteChildren();
	$('#ScenePanelContainer_tooltip')
	.BCreateChildren(`<DOTAScenePanel antialias="true" hittest="false" unit="${creepname}" particleonly="false" />`)
}