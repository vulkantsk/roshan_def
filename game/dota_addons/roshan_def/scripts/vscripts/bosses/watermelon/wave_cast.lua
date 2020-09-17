LinkLuaModifier("modifier_watermelon_wave_cast", "bosses/watermelon/wave_cast", 0)

watermelon_wave_cast = class({})

function watermelon_wave_cast:GetChannelTime()
	return self:GetSpecialValueFor("channel_time")
end

function watermelon_wave_cast:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_watermelon_wave_cast", {duration = self:GetChannelTime()})
end

function watermelon_wave_cast:OnChannelFinish(bInterrupted)
	if bInterrupted then
		self:GetCaster():RemoveModifierByName("modifier_watermelon_wave_cast")
	end
end

modifier_watermelon_wave_cast = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	CheckState = function() return {
		[MODIFIER_STATE_INVULNERABLE] = true
	}
	end
})

function modifier_watermelon_wave_cast:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	self:OnIntervalThink()
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
	self:GetCaster():StartGesture(ACT_DOTA_CHANNEL_ABILITY_4)
end

function modifier_watermelon_wave_cast:OnIntervalThink()
	if not IsServer() then return end
	local wave_ability = self:GetCaster():FindAbilityByName("watermelon_wave")
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("search_radius"), wave_ability:GetAbilityTargetTeam(), wave_ability:GetAbilityTargetType(), wave_ability:GetAbilityTargetFlags(), 0, false)
	for _, enemy in pairs(enemies) do
		self:GetCaster():SetCursorPosition(enemy:GetAbsOrigin())
		wave_ability:OnSpellStart()
	end
end

function modifier_watermelon_wave_cast:OnDestroy()
	self:GetCaster():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
end