ability_test_1 = class({})

function ability_test_1:OnSpellStart()
	BossSpawner:SpawnBoss(4)
end

ability_test_2 = class({})

function ability_test_2:OnSpellStart()
	BossSpawner:SpawnBoss(10)
end

ability_test_3 = class({})

function ability_test_3:OnSpellStart()
	BossSpawner:SpawnBoss(6)
end

ability_test_4 = class({})

function ability_test_4:OnSpellStart()
	BossSpawner:SpawnBoss(index)
end

ability_test_5 = class({})

function ability_test_5:OnSpellStart()
	Sounds:CreateGlobalLoopingSound( "boss_spawn")
end

ability_test_6 = class({})

function ability_test_6:OnSpellStart()
	Sounds:RemoveGlobalLoopingSound( "boss_spawn")
end
