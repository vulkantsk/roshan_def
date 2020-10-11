if Vote == nil then
	Vote = class({})
end

Vote.DATA = 
{
    [0] = {}, 
    [1] = {}, 
    [2] = {}, 
    [3] = {}, 
}

function Vote:Init()
    CustomGameEventManager:RegisterListener('player_vote_game_difficulty', Dynamic_Wrap(Vote, 'OnVote'))
end

Vote.DIFFICULTIES_ENUM = 
{
    [0] = "Herald",
    [1] = "Legend",
    [2] = "Divine",
    [3] = "Immortal"
}

--[[{
   difficulty                      	= 2 (number)
   PlayerID                        	= 0 (number)
   is_host                         	= 1 (number)
}]]

function Vote:OnVote(data)
    if Vote:NotContains(data.PlayerID) then
        table.insert(Vote.DATA[data.difficulty], data.PlayerID)
    end
    
    DeepPrintTable(data)
    DeepPrintTable(Vote.DATA)
end

function Vote:OnGameStarted()
    local difficulty = 0
    local lastPlayers = 0
   
    for diff, players in pairs(Vote.DATA) do 
        if #players > lastPlayers then
            lastPlayers = #players
            difficulty = diff
        end
    end

    Spawn:OnDifficultyChosen(difficulty)
end

function Vote:NotContains(pid)
    for diff, players in pairs(Vote.DATA) do 
        for _, id in pairs(players) do
            if pid == id then
                return false
            end
        end
    end

    return true
end