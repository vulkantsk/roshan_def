if not tester then 
	tester = class({})
	tester.testers_ids = {}
end
__util__.ModuleRequire(...,'data')
__util__.ModuleRequire(...,'modifiers')
local config = tester.config
function tester:Init()
	tester:ParserUnits()
	tester:ParserItems()
	local data = {}
	for biom_name,__ in pairs(config.biomes) do
		table.insert(data,biom_name)
	end
	CustomNetTables:SetTableValue('testers', '__forest__', data)
	--
	-- 	client events (testers.js)
	--
	CustomGameEventManager:RegisterListener("OnTesterPanelActivate", Dynamic_Wrap(tester, 'OnTesterPanelActivate'))
end
function CreepAbility(hero,units)
local full = units
local ability = {}
	for i = 1,24 do
		if full[hero] and full[hero]["Ability" .. i] ~= '' and full[hero]["Ability" .. i]  then			
			ability[full[hero]["Ability" .. i]] = true
		end
	end
	return ability
end

function tester:ParserItems()
	-- local data = {}
	local items_dota = LoadKeyValues('scripts/npc/items.txt')
	local override = LoadKeyValues('scripts/npc/npc_abilities_override.txt')
	local items_custom = LoadKeyValues('scripts/npc/npc_items_custom.txt')
	for k,v in pairs(__util__.table.merge(items_dota,items_custom)) do
		if (type(v) == 'table' 
			and not tester.items_remove[k]
			-- and not k:find('recipe')
			-- and not k:find('rune')
			-- and not k:find('bag_of_gold')
			-- and not k:find('bonus_health')
			and not k:find('dummy')
			and v.ItemRecipe ~= 1
			and override[k] ~= 'REMOVE'
			and not k:find('test')) then 
			local find = false;
			for _,_v in pairs(tester.items_match) do
				if k:find(_v) then 
					find = true
					break
				end
			end
			if not find then 
				CustomNetTables:SetTableValue('testers', '__items__' .. k, {}) -- fixed limit bytes
			end
		end
	end
	-- CustomNetTables:SetTableValue('testers', '__items__', data)  // 18900 bytes in var "data" (max 16000) =(
end

function tester:ParserUnits()
	local data = {}
	local units = LoadKeyValues('scripts/npc/npc_units_custom.txt')
	-- local units_dota = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
	for k,v in pairs(units) do
		if (type(v) == 'table' 
			and v.BaseClass
			and not tester.creep_remove[k]
			-- and not k:find('test') 
			-- and not k:find('ritual')
			and k ~= 'npc_dota_wraith_king_frozen_throne'
			and k ~= 'npc_dota_target_dummy'
			and k ~= 'npc_dummy_unit'
			and v.BaseClass ~= 'npc_dota_companion'
			and v.Model ~= 'models/development/invisiblebox.vmdl'
			and v.MovementCapabilities ~= 'DOTA_UNIT_CAP_MOVE_NONE') then 
		
			local find = false;
			for _,_v in pairs(tester.creep_match) do
				if k:find(_v) then 
					find = true
					break
				end
			end
			if not find then 
				local abilities = CreepAbility(k,units)
				if (not abilities['dummy_passive_vulnerable'] and not abilities['portal_passive']) then
					local biome = nil
					for biom_name,creeps in pairs(config.biomes) do
						if creeps[k] then 
							-- print(k)
							biome =biom_name
						end
					end
					CustomNetTables:SetTableValue('testers', '__creep__' .. k, {
						IsBoss = v.IsBossMonster == 1,
						biome = biome
					})
				end
			end
		end
	end
end
 -- tester:ParserUnits()
function tester:OnTesterPanelActivate(data)
	local id = data.id -- enum 
	local pID = data.PlayerID
	local hHero = PlayerResource:GetSelectedHeroEntity(pID)
	if not tester.testers_ids['Player_' .. pID] 
		or not tester.testers_ids['Player_' .. pID].developer 
		or tester.testers_ids['Player_' .. pID].developer < 1  then 
		return
	end
	local dev = tester.testers_ids['Player_' .. pID].developer
	if dev > 1 and not GameRules:IsCheatMode() then return end
	if id == 0 then 
		if (data.bFriendly == nil or data.name == nil ) then return end
		local iTeam = data.bFriendly == 1 and  hHero:GetTeamNumber() or (hHero:GetTeamNumber() == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS)
		local unit = CreateUnitByName( data.name, hHero:GetOrigin() + RandomVector(RandomFloat(150, 350)), true, nil, nil, iTeam )
		if unit then 
			unit:SetControllableByPlayer(pID, false)
		end
	end
	if id == 1 and data.name then 
		hHero:AddItemByName(data.name)
	end
	if id == 2  then
		GameRules:GetGameModeEntity():SetFogOfWarDisabled(not tester.fow_activate)
		tester.fow_activate = not tester.fow_activate  
		AddFOWViewer(hHero:GetTeamNumber(), hHero:GetOrigin(), 20000, 30, false)
	end
	if id == 3 then 
		if hHero:HasModifier('modifier_invulnerable') then 
			hHero:RemoveModifierByName('modifier_invulnerable')
			return
		end
		hHero:AddNewModifier(hHero, nil, 'modifier_invulnerable', {duration = -1})
	end
	if id == 4 then 
		if hHero:HasModifier('modifier_max_movespeed_testers') then 
			hHero:RemoveModifierByName('modifier_max_movespeed_testers')
			return
		end
		hHero:AddNewModifier(hHero, nil, 'modifier_max_movespeed_testers', {duration = -1})
	end
	if id == 5 then 
		hHero:ModifyGold(10000, false, 0)
	end
	if id == 6 then 
		hHero:AddExperience(XP_PER_LEVEL_TABLE[hHero:GetLevel()] - XP_PER_LEVEL_TABLE[math.max(hHero:GetLevel() - 1,0)], 0, false,true)
	end
	if id == 7 then 
		local length = #XP_PER_LEVEL_TABLE
		hHero:AddExperience(XP_PER_LEVEL_TABLE[length], 0, false,true)
	end
	if id == 9 or id == 8 then 
		hHero:AddStackModifier({
			modifier = 'tome_strenght_modifier',
			count = 10,
			caster = hHero,
		})
	end
	if id == 10 or id == 8 then 
		hHero:AddStackModifier({
			modifier = 'tome_agility_modifier',
			count = 10,
			caster = hHero,
		})
	end
	if id == 11 or id == 8 then 
		hHero:AddStackModifier({
			modifier = 'tome_intelect_modifier',
			count = 10,
			caster = hHero,
		})
	end
end

-- tester:ParserUnits()