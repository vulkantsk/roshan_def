if not donate_module then 
	donate_module = class({})
	donate_module.config = {
		config = {},
		players = {},
	}
end

function donate_module:Init()
	CustomGameEventManager:RegisterListener("donate_pick_item", Dynamic_Wrap(donate_module, 'OnDonatePickItem'))
	CustomGameEventManager:RegisterListener( "donate_state_update", Dynamic_Wrap( donate_module, "DonateStateUpdate" ) )
end

function donate_module:DonateStateUpdate(data)
	local amount = 0
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(i) then
			amount = amount + 1
			if amount > 1 then
				return
			end
		end
	end
	local use = CustomNetTables:GetTableValue( "donate", 'GLOBAL')
	use = use and use.use_donate == 1
	CustomNetTables:SetTableValue( "donate", 'GLOBAL', {
		use_donate = not use,
	} )
end

function donate_module:OnDonatePickItem(data)
	local use = CustomNetTables:GetTableValue( "donate", 'GLOBAL')
	use = use and use.use_donate == 0
	if use then return end

	local dataPlayer = donate_module.config.players['Player_' .. data.PlayerID]
	if not dataPlayer then return end
	local PlayerData = {}
	for k,v in pairs(dataPlayer) do
		if k ~= 'hidden' then 
			PlayerData[v] = true
		end
	end
	local itemData = donate_module.config.config[tonumber(data.item_id)]
	if itemData and PlayerData[data.item_id - 1] then 
		local itemname = itemData.item_name
		if not itemname then return end
		local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
		local has_empty_slot = false;
		for i=0, DOTA_ITEM_SLOT_9 do
			has_empty_slot = has_empty_slot or not hero:GetItemInSlot(i)
			if has_empty_slot then break; end
		end
		if not has_empty_slot then return end
		hero:AddItemByName(itemname)
		local tbl = CustomNetTables:GetTableValue('request', 'Player_' .. data.PlayerID)
		tbl['Items'] = tbl['Items'] or {}
		for k,v in pairs(tbl['Items']) do
			if v == data.item_id - 1 then 
				tbl['Items'][k] = nil
				break;
			end
		end
		CustomNetTables:SetTableValue('request', 'Player_' .. data.PlayerID , tbl)
	end


end
