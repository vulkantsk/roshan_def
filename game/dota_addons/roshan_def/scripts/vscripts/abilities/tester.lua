ability_test_1 = class({})

function ability_test_1:OnSpellStart()
	GameRules:SendCustomMessage("#Game_notification_end_game_message",0,0)
end

ability_test_2 = class({})

function ability_test_2:OnSpellStart()
	EmitGlobalSound("town_road_2")
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
