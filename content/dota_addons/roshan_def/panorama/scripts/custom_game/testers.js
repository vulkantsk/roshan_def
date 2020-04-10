const _ = GameUI.CustomUIConfig()._;
function SelectSettings(id){
	_.each($('#ContentContainer').Children(),(child) => {
		child.SetHasClass('Visible', child.id == id)
	})
}
function __OnItemSearch(){
	let text = $('#item_search').text.toUpperCase();
	var container = $("#items_select");
	_.each(container.Children(),function(child){
		child.SetHasClass('Hidden', !$.Localize('dota_tooltip_ability_' + child.itemname).toUpperCase().match(text))
	})

}
function __OnCreepSearch(){
	var text = $('#creep_search').text.toUpperCase();
	let isBossSearch = text == 'BOSS' || text == 'БОСС'
	var container = $("#creeps_select");
	_.each(container.Children(),function(child){
		if (child.id == 'creeps_select_bosses') return
		child.SetHasClass('Hidden',!$.Localize(child.__name__).toUpperCase().match(text))
		if (child.BHasClass('Hidden')){
			child.SetHasClass('Hidden', !(child.__biome__ == text))
		}
	})

	_.each(container.FindChild('creeps_select_bosses').Children(),function(child){
		child.SetHasClass('Hidden',!$.Localize(child.__name__).toUpperCase().match(text))
		if (child.BHasClass('Hidden')){
			child.SetHasClass('Hidden', !(child.__biome__ == text))
		}
	})
} 

function SelectForestCreeps(forest){
	$('#creep_search').text = forest;
}

function GeneralClickToggle(id){
	GameEvents.SendCustomGameEventToServer('OnTesterPanelActivate',{
		id:id, 
	})
}

function FillItemsContent(){
	let container = $('#items_select')
	container.RemoveAndDeleteChildren()
	let data = CustomNetTables.GetAllTableValues('testers');
	let data_sort = []
	_.each(data,(value) =>{
		if (value.key.indexOf('__items__') !== 0) return 
		data_sort.push(value.key.replace('__items__',''))	
	})
	data_sort.sort()
	_.each(data_sort,(value) =>{ 
		let panel = $.CreatePanel('DOTAItemImage',container,value);
		panel.itemname = value
		panel.AddClass('item_panel');
		panel.SetPanelEvent('onactivate', () => {
			GameEvents.SendCustomGameEventToServer('OnTesterPanelActivate',{
				name:value,
				id:1, 
			})
		}) 
	})
}

function FillCreepContent(){
	let container = $('#creeps_select')
	container.RemoveAndDeleteChildren()
	container.BCreateChildren('<Panel id="creeps_select_bosses" class="row-wrap" />')
	let boss_container = container.FindChild('creeps_select_bosses')
	let data = CustomNetTables.GetAllTableValues('testers');
	let _data_ = []
	_.each(data,(value) =>{
		if (value.key.indexOf('__creep__') !== 0) return 
		let name = value.key.replace('__creep__','')
		_data_.push({
			name:name,
			data:value.value,
		})  
	})	
	_data_.sort(function(a,b){
		let _b = b.name;
		let _a = a.name;
		return _a > _b ? 1 : _a < _b ? -1 : 0;
	})
	_.each(_data_,(value) =>{
		// if (value.key.indexOf('__creep__') !== 0) return 

		let data = value.data 
		let name = value.name
		let panel = $.CreatePanel('Panel',data.IsBoss == 1 ? boss_container : container,name);
		panel.AddClass('creep_panel');
		panel.__IsBoss__ = data.IsBoss == 1
		panel.__biome__ = data.biome && data.biome.toUpperCase() || null
		panel.__name__ = name
		panel.SetHasClass('IsBoss', panel.__IsBoss__)
		panel.SetPanelEvent('onmouseover',() =>{
			$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "CreepTooltip", 
						"file://{resources}/layout/custom_game/tooltips/CreepTooltip.xml", 'creepname=' + name)
		})
		panel.SetPanelEvent( "onmouseout",() => {
			$.DispatchEvent("UIHideCustomLayoutTooltip", panel, "CreepTooltip");
		});
		panel.SetPanelEvent('onactivate', () => {
			GameEvents.SendCustomGameEventToServer('OnTesterPanelActivate',{
				name:panel.__name__,
				bFriendly:$('#FriendlySpawn').checked,
				id:0,
			})
		}) 
		$.CreatePanel('Label',panel,'').text = $.Localize(name)
	})
}

(function(){
	$('#MainPanel').AddClass('Hidden')
	let isDev = CustomNetTables.GetTableValue('request', 'Player_' + Game.GetLocalPlayerInfo().player_id)
	let is_cheat = CustomNetTables.GetTableValue('request', 'settings').bCheatMode == 1
	$.Msg(isDev.Developer)
	if (isDev && isDev.Developer > 0){
		if (isDev.Developer > 1 && !is_cheat) return

		$('#MainPanel').RemoveClass('Hidden')
		FillCreepContent();
		FillItemsContent();
		let rbtn_container = $('#forest_container_btn')
		rbtn_container.RemoveAndDeleteChildren()
		let forests = CustomNetTables.GetTableValue('testers', '__forest__')
		_.each(forests,(value) => {
			rbtn_container.BCreateChildren(`<RadioButton groupname="forest_rbtn" onactivate="SelectForestCreeps('${value}')"> <Label text="${value}" /></RadioButton>`)
		})
	} 
	// $('##MainPanel').
})();