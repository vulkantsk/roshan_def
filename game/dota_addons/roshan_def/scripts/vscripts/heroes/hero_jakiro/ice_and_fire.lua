LinkLuaModifier("modifier_jakiro_ice_and_fire_ice_path_thinker", "heroes/hero_jakiro/ice_and_fire", 0)
LinkLuaModifier("modifier_jakiro_ice_and_fire_macropyre_thinker", "heroes/hero_jakiro/ice_and_fire", 0)
LinkLuaModifier("modifier_jakiro_ice_and_fire_out_of_macropyre", "heroes/hero_jakiro/ice_and_fire", 0)
LinkLuaModifier("modifier_jakiro_disable_turning", "heroes/hero_jakiro/modifier_jakiro_disable_turning", 0)

jakiro_ice_and_fire = class({})

function jakiro_ice_and_fire:GetAbilityDamageType()
	if self:GetCaster():HasScepter() then
		return DAMAGE_TYPE_PURE
	end
	return DAMAGE_TYPE_MAGICAL
end

function jakiro_ice_and_fire:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local table = {
		duration = self:GetSpecialValueFor("ice_path_duration"),
		start_pos_x = caster:GetAbsOrigin().x,
		start_pos_y = caster:GetAbsOrigin().y,
		end_pos_x = point.x,
		end_pos_y = point.y
	}
	CreateModifierThinker(caster, self, "modifier_jakiro_ice_and_fire_ice_path_thinker", table, point, caster:GetTeamNumber(), false)
	table.duration = self:GetSpecialValueFor("macropyre_duration")

	caster:AddNewModifier(caster, self, "modifier_jakiro_disable_turning", {duration = self:GetSpecialValueFor("casts_delay")})
	caster:SetContextThink(self:GetName(), function()
		CreateModifierThinker(caster, self, "modifier_jakiro_ice_and_fire_macropyre_thinker", table, point, caster:GetTeamNumber(), false)
		caster:AddNewModifier(caster, self, "modifier_jakiro_disable_turning", {duration = self:GetSpecialValueFor("casts_delay")})
	end, self:GetSpecialValueFor("casts_delay"))
end

modifier_jakiro_ice_and_fire_ice_path_thinker = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end
})

function modifier_jakiro_ice_and_fire_ice_path_thinker:OnCreated(keys)
	local parent = self:GetParent()
	if IsServer() then
		self.start_pos = Vector(keys.start_pos_x, keys.start_pos_y, parent:GetAbsOrigin().z)
		self.end_pos = Vector(keys.end_pos_x, keys.end_pos_y, parent:GetAbsOrigin().z)
		local end_pos = self.start_pos + (self.end_pos - self.start_pos):Normalized() * self:GetAbility():GetCastRange(parent:GetAbsOrigin(), parent)
		self.end_pos = end_pos

		self:GetCaster():EmitSound("Hero_Jakiro.IcePath")

		Timers:CreateTimer(0.1, function()
			self:GetCaster():EmitSound("Hero_Jakiro.IcePath.Cast")
		end)
		local duration = self:GetAbility():GetSpecialValueFor("ice_path_duration") + self:GetAbility():GetSpecialValueFor("casts_delay")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(pfx, 0, self.start_pos)
		ParticleManager:SetParticleControl(pfx, 1, end_pos)
		ParticleManager:SetParticleControl(pfx, 2, Vector(0, 0, duration))
		self:AddParticle(pfx, false, false, -1, false, false)

		local pfx_icicles = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(pfx_icicles, 0, self.start_pos)
		ParticleManager:SetParticleControl(pfx_icicles, 1, end_pos)
		ParticleManager:SetParticleControl(pfx_icicles, 2, Vector(keys.duration, 0, 0))
		ParticleManager:SetParticleControl(pfx_icicles, 9, self.start_pos)
		self:AddParticle(pfx_icicles, false, false, -1, false, false)


		self:StartIntervalThink(FrameTime())
	end
end

function modifier_jakiro_ice_and_fire_ice_path_thinker:OnIntervalThink()
	if IsServer() then
		local enemies_in_path = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self.start_pos, self.end_pos, nil, self:GetAbility():GetSpecialValueFor("ice_path_width"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags())
		for _, enemy in pairs(enemies_in_path) do
			if not enemy:HasModifier("modifier_stunned") then
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetRemainingTime()})
			end
		end
	end
end

modifier_jakiro_ice_and_fire_macropyre_thinker = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end
})

function modifier_jakiro_ice_and_fire_macropyre_thinker:OnCreated(keys)
	local parent = self:GetParent()
	if IsServer() then
		self.start_pos = Vector(keys.start_pos_x, keys.start_pos_y, parent:GetAbsOrigin().z)
		self.end_pos = Vector(keys.end_pos_x, keys.end_pos_y, parent:GetAbsOrigin().z)
		local end_pos = self.start_pos + (self.end_pos - self.start_pos):Normalized() * self:GetAbility():GetCastRange(parent:GetAbsOrigin(), parent)

		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self.start_pos)
		ParticleManager:SetParticleControl(pfx, 1, end_pos)
		ParticleManager:SetParticleControl(pfx, 2, Vector(keys.duration, 0, 0))
		ParticleManager:SetParticleControl(pfx, 3, self.start_pos)
		self:AddParticle(pfx, false, false, -1, false, false)

		self:GetCaster():EmitSound("Hero_Jakiro.Macropyre.Cast")
		self:StartIntervalThink(1 / 10)
	end
end

function modifier_jakiro_ice_and_fire_macropyre_thinker:OnIntervalThink()
	local enemies_in_path = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self.start_pos, self.end_pos, nil, self:GetAbility():GetSpecialValueFor("macropyre_width"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags())
	for _, enemy in pairs(enemies_in_path) do
		ApplyDamage({
			victim = enemy,
			attacker = self:GetCaster(),
			ability = self:GetAbility(),
			damage = self:GetAbility():GetSpecialValueFor("macropyre_damage_per_sec") / 10,
			damage_type = self:GetAbility():GetAbilityDamageType()
		})
	end
end