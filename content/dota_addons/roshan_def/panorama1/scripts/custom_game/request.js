"use strict"
const _ = GameUI.CustomUIConfig()._;

function StrFormattingCountSymbol(str,count){
	var c = str.length
	str = str.substr(0,count)
	var c = str.length
	while (str.length < count){
		str += "0";
	}
	return str;

} 

function FormattingTimeToRound(time,num){
	var str = String(time)
	while (str.length < (num || 2))
		str = '0' + str
	return str
}
function FormatSecMMTime(Isms,time){
	var time = time || Game.GetDOTATime(false, false)
	var ms = time * 10000 % 10000
    var seconds = Math.floor(time)
    var minutes = Math.floor(parseInt(time, 10) / 60);
	var seconds = Math.floor(parseInt(time, 10) - minutes * 60);
	var hours = FormattingTimeToRound(Math.floor(minutes / 60),1)
	return FormattingTimeToRound(minutes) + ":"  + FormattingTimeToRound(seconds) + (Isms ?  "." +  StrFormattingCountSymbol(String(Math.floor(ms)),2) : '');
}

function FillLeaderBoards(parentName,snippet,nettables){	
	const parent = $('#' + parentName);
	const bIsSpeedRun = parentName == 'leaderboardsContainer_speedrun'
	const all = CustomNetTables.GetTableValue('request',nettables)
	const allPlayer = CustomNetTables.GetTableValue('request','Player_' + Game.GetLocalPlayerInfo().player_id)
	if (!all) return 
 	const AllTime = all[2]
	const Season = all[1]
	const pID_LOCAL = Game.GetLocalPlayerInfo().player_steamid

	let sortArrayKey = function(a,b,key){
		let a_ = Number(a[key])
		let b_ = Number(b[key])
		 	return a_ > b_ ? -1 : a_ < b_ ? 1 : 0
	}    
	let sortObject = function(obj,bIsRank){
		let _obj = []
		for (var i in obj){
			_obj.push(obj[i])
		}

		_obj.sort(function(a,b){
			if (bIsRank){
				return b['rank'] > a['rank'] ? -1 : b['rank'] < a['rank'] ? 1 : 0
			}
			let Score = sortArrayKey(a,b,'Score')
			let WinAmount = sortArrayKey(a,b,'WinAmount')
			let GameAmount = sortArrayKey(a,b,'GameAmount')
			return Score == 0 
			? WinAmount == 0 
				? GameAmount
				: WinAmount
			: Score
		})
		return _obj
	}  
	const container1 = parent.FindChildTraverse("Ranking_top_10_global")
	container1.RemoveAndDeleteChildren()
	const container2 = parent.FindChildTraverse("Ranking_top_10_season")
	container2.RemoveAndDeleteChildren()
	const container3 = parent.FindChildTraverse("Ranking_nearby_global")
	container3.RemoveAndDeleteChildren()
	const container4 = parent.FindChildTraverse("Ranking_nearby_season")
	container4.RemoveAndDeleteChildren()
	const panels = [
		container1, 
		container2,
		container3, 
		container4,
	]    

 	const allData = []  
	allData.push(sortObject(AllTime),sortObject(Season))
	if (!!allPlayer){ 
		allData.push(sortObject(allPlayer.PlayersNearby[2],true),sortObject(allPlayer.PlayersNearby[1],true))
	}
	_.each(allData,function(data,index){
		const IsAllTime = index == 0
		const IsAllTime_nearby = index == 3
		let amount = 0
		_.each(data,function(dataPlayer,id){
			amount = dataPlayer['rank'] || (amount + 1); 
			let steamid = dataPlayer.SteamID
			var parent = $.CreatePanel('Panel',panels[index],'')
			parent.BLoadLayoutSnippet(snippet)
			parent.SetDialogVariable('leader_loses', dataPlayer.GameAmount - dataPlayer.WinAmount)
			parent.SetDialogVariable('leader_wins', dataPlayer.WinAmount)
			parent.SetDialogVariable('leader_score', dataPlayer.Score)
			parent.SetHasClass('LocalPlayer', dataPlayer.SteamID == pID_LOCAL)
			parent.FindChildTraverse('PlayerImageLeader').steamid = steamid;
			parent.FindChildTraverse('PlayerLeader').BCreateChildren('<DOTAUserName steamid="' + steamid + '" id="PlayerNameLabel" />')
			parent.FindChildTraverse('LeaderRankContainer').BCreateChildren( amount <= 10
			? '<Panel id="LeaderIcon" class="position_'+ amount + ' leader_top'+ ( amount > 3 ? '_2' : '') + '" />'
			: '<Label text="'+ amount +'" />')	 	
		})
	})	 

}

function SpeedRunBoardFill(){
	const all = CustomNetTables.GetTableValue('request','leaderboards_speenRun')
	if (!all) return 
 
	for (let game in all){
		let data = all[game];
		_.each(data,function(value,key){
			let diff_value = key.replace('Diff_','');
			let diff_panel = $("#" + game + '_' + diff_value);
			diff_panel.RemoveAndDeleteChildren()
			let amount = 0
			_.each(value,function(userData){
				amount++ //(amount + 1); 
				let panel = $.CreatePanel('Panel',diff_panel,'');
				panel.BLoadLayoutSnippet('player_row_speenRun')
				panel.FindChildTraverse('GameTime_label').text = FormatSecMMTime(true,userData[game + '_' + diff_value])
				panel.FindChildTraverse('PlayerImageLeader').steamid = userData['SteamID'];
				panel.FindChildTraverse('PlayerLeader').BCreateChildren('<DOTAUserName steamid="' + userData['SteamID'] + '" id="PlayerNameLabel" />')
				panel.FindChildTraverse('LeaderRankContainer').BCreateChildren( amount <= 10
			? '<Panel id="LeaderIcon" class="position_'+ amount + ' leader_top'+ ( amount > 3 ? '_2' : '') + '" />'
			: '<Label text="'+ amount +'" />')	
			})
		})
	}
}

function OnClickedRBox(bSpeedRun){
	let main_parent = $('#' + (bSpeedRun ? 'leaderboardsContainer_speedrun' : 'leaderboardsContainer'))
	let current = main_parent.FindChildTraverse('rbtn_current').checked // $('#rbtn_current').checked
	let _global = main_parent.FindChildTraverse('rbtn_global').checked 
 
	let my_position =  main_parent.FindChildTraverse('my_position').checked 
	let top_10 =  main_parent.FindChildTraverse('top_10').checked 

	const obj = {
		'Ranking_top_10_global':_global && top_10,
		'Ranking_top_10_season':current && top_10,
		'Ranking_nearby_global':_global && my_position,
		'Ranking_nearby_season':current && my_position,
	}
	_.each(main_parent.FindChildTraverse('RankingPlayerContent').Children(),function(child){
		child.SetHasClass('Visible', obj[child.id])
	})
} 

function OnClickedRBoxSpeedRun(){
	let tagName = $('#rbtn_standart_map').checked ? 'standart_' : 'turbo_';
	let pickingDiff = $("#rbtn_difficuilt_0");

	_.each($("#DifficuiltButtons").Children(),function(child){
		pickingDiff = child.checked ? child : pickingDiff
	})
	let diffIndex_select = pickingDiff.id.replace('rbtn_difficuilt_','');
	_.each($("#leaderboardsContainer_speedrun").FindChildTraverse('RankingPlayerContent').Children(),function(child){
		
		child.SetHasClass('Visible', (tagName + diffIndex_select) == child.id)
	})
}

function UpdateButtobBar(){
	const container = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse('ButtonBar')

	if (container){
		let button = container.FindChild('ButtonLeaderBoards') || $.CreatePanel('Button',container,'ButtonLeaderBoards')
		button.style.backgroundImage = `url('file://{images}/request/leaderboards.png')`
		button.style.backgroundSize = "100% 100%";

		button.SetPanelEvent('onactivate',() => {
			$("#leaderboardsContainer").ToggleClass('Visible')
			$("#leaderboardsContainer_speedrun").RemoveClass('Visible')
		})

		button.SetPanelEvent('onmouseover',() => {
			$.DispatchEvent("DOTAShowTextTooltip", button, '#LeaderBoards');
		})

		button.SetPanelEvent('onmouseout',() => {
			$.DispatchEvent("DOTAHideTextTooltip");
		})

		let _button = container.FindChild('ButtonLeaderBoards_speedRun') || $.CreatePanel('Button',container,'ButtonLeaderBoards_speedRun')
		_button.style.backgroundImage = `url('file://{images}/request/leaderboards.png')`
		_button.style.backgroundSize = "100% 100%";
		_button.style.washColor = 'lime'; 

		_button.SetPanelEvent('onactivate',function(){
			$("#leaderboardsContainer_speedrun").ToggleClass('Visible')
			$("#leaderboardsContainer").RemoveClass('Visible')
		})

		_button.SetPanelEvent('onmouseover',() => {
			$.DispatchEvent("DOTAShowTitleTextTooltip", _button, '#LeaderBoards_speedrun','ONLY_SOLO_MODE');
		})

		_button.SetPanelEvent('onmouseout',() => {
			$.DispatchEvent("DOTAHideTitleTextTooltip"); 
		})
	}
	
}



(function(){ 
	FillLeaderBoards('leaderboardsContainer','player_row_leaderboards','leaderboards');
	SpeedRunBoardFill();
	// FillLeaderBoards('leaderboardsContainer_speedrun','player_row_speenRun','leaderboards_speenRun');
	UpdateButtobBar();
})()