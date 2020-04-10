ability_test_1 = class({})

function ability_test_1:OnSpellStart()
	Sounds:CreateGlobalLoopingSound( "boss_spawn")
end

ability_test_2 = class({})

function ability_test_2:OnSpellStart()
	Sounds:RemoveGlobalLoopingSound( "boss_spawn")
end

ability_test_3 = class({})

function ability_test_3:OnSpellStart()

end

ability_test_4 = class({})

function ability_test_4:OnSpellStart()

end

ability_test_5 = class({})

function ability_test_5:OnSpellStart()

end

ability_test_6 = class({})

function ability_test_6:OnSpellStart()

end
