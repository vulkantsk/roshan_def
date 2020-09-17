watermelon_tentacle = class({})

function watermelon_tentacle:OnSpellStart()
	CreateUnitByName("npc_dota_watermelon_tentacle", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
end