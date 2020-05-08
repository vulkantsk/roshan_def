ability_test_1 = class({})

function ability_test_1:OnSpellStart()
	BossSpawner:FinalBossSpawner()
end

ability_test_2 = class({})

function ability_test_2:OnSpellStart()
	BossSpawner:InitBossMarathon()
end

ability_test_3 = class({})

function ability_test_3:OnSpellStart()
	BossSpawner:SpawnBoss(3)
end

ability_test_4 = class({})

function ability_test_4:OnSpellStart()
	BossSpawner:SpawnBoss(4)
end

ability_test_5 = class({})

function ability_test_5:OnSpellStart()
	Sounds:CreateGlobalLoopingSound( "boss_spawn")
end

ability_test_6 = class({})

function ability_test_6:OnSpellStart()
	Sounds:RemoveGlobalLoopingSound( "boss_spawn")
end
