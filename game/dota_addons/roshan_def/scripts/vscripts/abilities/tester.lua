ability_test_1 = class({})

function ability_test_1:OnSpellStart()
	GameRules:SendCustomMessage("#Game_notification_end_game_message",0,0)
end

ability_test_2 = class({})

function ability_test_2:OnSpellStart()
		FrostEvent.event_level = 5
		local owner = self:GetCaster()
		local rewards = FrostEvent.rewards[FrostEvent.event_level]
		if rewards.gold then
			GiveGoldPlayers(rewards.gold)
		end
		if rewards.item then
			owner:AddItemByName(rewards.item)
		end
		if rewards.pet then
			local pet = CreateUnitByName(rewards.pet, owner:GetAbsOrigin(), true, owner, owner, owner:GetTeam())
		end
end

ability_test_3 = class({})

function ability_test_3:OnSpellStart()
	BossSpawner:SpawnBoss(8)
end

ability_test_4 = class({})

function ability_test_4:OnSpellStart()
    BossSpawner:SpawnBoss(9)

end

ability_test_5 = class({})

function ability_test_5:OnSpellStart()
	Sounds:CreateGlobalLoopingSound( "boss_spawn")
end

ability_test_6 = class({})

function ability_test_6:OnSpellStart()
	Sounds:RemoveGlobalLoopingSound( "boss_spawn")
end
