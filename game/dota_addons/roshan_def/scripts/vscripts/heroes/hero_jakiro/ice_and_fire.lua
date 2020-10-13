LinkLuaModifier("modifier_jakiro_ice_and_fire_macropyre_thinker", "heroes/hero_jakiro/ice_and_fire", 0)
LinkLuaModifier("modifier_jakiro_disable_turning", "heroes/hero_jakiro/modifier_jakiro_disable_turning", 0)
LinkLuaModifier("modifier_jakiro_ice_and_fire_stun", "heroes/hero_jakiro/ice_and_fire", 0)

jakiro_ice_and_fire = class({})

function jakiro_ice_and_fire:GetAOERadius()
    return self:GetSpecialValueFor("macropyre_width")/2
end

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
		duration = self:GetSpecialValueFor("macropyre_duration"),
		start_pos_x = caster:GetAbsOrigin().x,
		start_pos_y = caster:GetAbsOrigin().y,
		end_pos_x = point.x,
		end_pos_y = point.y
	}
	CreateModifierThinker(caster, self, "modifier_jakiro_ice_and_fire_macropyre_thinker", table, point, caster:GetTeamNumber(), false)
	caster:AddNewModifier(caster, self, "modifier_jakiro_disable_turning", {duration = self:GetSpecialValueFor("casts_delay")})
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
		self.end_pos = end_pos

		local pfx = ParticleManager:CreateParticle("particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre.vpcf", PATTACH_WORLDORIGIN, parent)
		ParticleManager:SetParticleControl(pfx, 0, self.start_pos)
		ParticleManager:SetParticleControl(pfx, 1, self.end_pos)
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetSpecialValueFor("macropyre_duration"), 0, 0))
		ParticleManager:SetParticleControl(pfx, 3, self.end_pos)
		self:AddParticle(pfx, false, false, -1, false, false)

		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
		parent:EmitSound("Hero_Jakiro.Macropyre.Cast")
		self.sound = "hero_jakiro.macropyre.scepter"
		parent:EmitSound(self.sound)
	end
end

function modifier_jakiro_ice_and_fire_macropyre_thinker:OnDestroy()
	self:GetParent():StopSound(self.sound_fire_loop)
end

function modifier_jakiro_ice_and_fire_macropyre_thinker:OnIntervalThink()
	if IsServer() then
		local enemies_in_path = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self.start_pos, self.end_pos, nil, self:GetAbility():GetSpecialValueFor("macropyre_width"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags())
		local damage = self:GetAbility():GetSpecialValueFor("damage_per_sec") * self:GetAbility():GetSpecialValueFor("damage_interval")
		for _, enemy in pairs(enemies_in_path) do
			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType()
			})
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jakiro_ice_and_fire_stun", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
		end
	end
end

modifier_jakiro_ice_and_fire_stun = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	IsPurgeException = function() return true end,
	CheckState = function() return {
		[MODIFIER_STATE_STUNNED] = true
	}
	end
})

function modifier_jakiro_ice_and_fire_stun:OnCreated()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(pfx, false, false, -1, true, false)
end