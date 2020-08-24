LinkLuaModifier("modifier_pubg_square", "abilities/quest/pubg_square", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pubg_square_aura", "abilities/quest/pubg_square", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pubg_square_inside", "abilities/quest/pubg_square", LUA_MODIFIER_MOTION_NONE)

pubg_square = class({})

function pubg_square:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_pubg_square", nil)
	ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
--	ParticleManager:SetParticleControl(self.pfx_top, 0, self.pfx_top_right)
--	ParticleManager:SetParticleControl(self.pfx_top, 1, self.pfx_top_left)

end

function pubg_square:GetIntrinsicModifierName()
--	return "modifier_pubg_square"
end
--------------------------------------------------------
------------------------------------------------------------

modifier_pubg_square = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	IsAura = function(self) return true end,
	GetAuraRadius = function(self) return self.total_radius end,
	GetModifierAura = function(self) return "modifier_pubg_square_aura" end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	CheckState = function(self) return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}end,
})

function modifier_pubg_square:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		self.total_radius	= ability:GetSpecialValueFor("total_radius")

		local start_point	= parent:GetAbsOrigin()+Vector(0, 0, 100)
		self.step_radius	= ability:GetSpecialValueFor("step_radius")
		local start_width	= ability:GetSpecialValueFor("start_width")
		local start_height	= ability:GetSpecialValueFor("start_height")
		local half_width = start_width/2
		local half_height = start_height/2
		self.pfx_top_right = start_point + Vector(half_width,half_height,0)
		self.pfx_top_left = start_point + Vector(-half_width,half_height,0)

		self.pfx_bot_right = start_point + Vector(half_width,-half_height,0)
		self.pfx_bot_left = start_point + Vector(-half_width,-half_height,0)

		local speed_width	= ability:GetSpecialValueFor("speed_width")
		local speed_height	= ability:GetSpecialValueFor("speed_height")
		self.tick_interval 		= ability:GetSpecialValueFor("tick_interval")
		self.delta_width	= speed_width*self.tick_interval/2
		self.delta_height	= speed_height*self.tick_interval/2

--		local effect = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
		local effect = "particles/units/heroes/hero_wisp/wisp_tether.vpcf"
--		local effect = "particles/units/heroes/hero_wisp/wisp_tether_agh.vpcf"

		self.pfx_top = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_top, 0, self.pfx_top_right)
		ParticleManager:SetParticleControl(self.pfx_top, 1, self.pfx_top_left)

		self.pfx_bot = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_bot, 1, self.pfx_bot_left)
		ParticleManager:SetParticleControl(self.pfx_bot, 0, self.pfx_bot_right)

		self.pfx_left = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_left, 0, self.pfx_top_left)
		ParticleManager:SetParticleControl(self.pfx_left, 1, self.pfx_bot_left)

		self.pfx_right = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_right, 0, self.pfx_top_right)
		ParticleManager:SetParticleControl(self.pfx_right, 1, self.pfx_bot_right)

		self:AddParticle(self.pfx_top, true, false, 111, false, false)
		self:AddParticle(self.pfx_bot, true, false, 111, false, false)
		self:AddParticle(self.pfx_left, true, false, 111, false, false)
		self:AddParticle(self.pfx_right, true, false, 111, false, false)

		self:StartIntervalThink(self.tick_interval)
	end
end

function modifier_pubg_square:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local delta_height = self.delta_height
	local delta_width = self.delta_width

	self.pfx_top_right = self.pfx_top_right + Vector(delta_width,delta_height,0)
	self.pfx_top_left = self.pfx_top_left + Vector(-delta_width,delta_height,0)

	self.pfx_bot_right = self.pfx_bot_right + Vector(delta_width,-delta_height,0)
	self.pfx_bot_left = self.pfx_bot_left + Vector(-delta_width,-delta_height,0)
	
	ParticleManager:SetParticleControl(self.pfx_top, 0, self.pfx_top_right)
	ParticleManager:SetParticleControl(self.pfx_top, 1, self.pfx_top_left)

	ParticleManager:SetParticleControl(self.pfx_bot, 0, self.pfx_bot_right)
	ParticleManager:SetParticleControl(self.pfx_bot, 1, self.pfx_bot_left)

	ParticleManager:SetParticleControl(self.pfx_left, 0, self.pfx_top_left)
	ParticleManager:SetParticleControl(self.pfx_left, 1, self.pfx_bot_left)

	ParticleManager:SetParticleControl(self.pfx_right, 0, self.pfx_top_right)
	ParticleManager:SetParticleControl(self.pfx_right, 1, self.pfx_bot_right)
	
	local step_radius = self.step_radius
	local x_start_pos = self.pfx_bot_left.x + step_radius
	local y_start_pos = self.pfx_bot_left.y + step_radius
	local x_end_pos = self.pfx_top_right.x - step_radius
	local y_end_pos = self.pfx_top_right.y - step_radius
	local point_top_left  = Vector(x_start_pos, y_end_pos,100)
	local point_top_right = Vector(x_end_pos, y_end_pos, 100)
	local point_bot_left  = Vector(x_start_pos, y_start_pos,100)
	local point_bot_right = Vector(x_end_pos, y_start_pos,100)

	local y_current_pos = y_start_pos
	
	while y_current_pos < y_end_pos do
		local vStartPos = Vector(x_start_pos, y_current_pos, 0)
		local vEndPos = Vector(x_end_pos, y_current_pos, 0)
		local search_width = step_radius*math.sqrt(2)

		y_current_pos = y_current_pos + step_radius
--		local search_width = (self.pfx_top_right.y - self.pfx_bot_right.y)/2

		local teams = DOTA_UNIT_TARGET_TEAM_BOTH
		local types = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE

		local units = FindUnitsInLine(parent:GetTeam(), vStartPos, vEndPos, nil, search_width, teams, types, flags)
		
		for _,unit in pairs(units) do
			unit:AddNewModifier(parent, ability, "modifier_pubg_square_inside",{duration = self.tick_interval+0.1})
		end	
	end

	local vStartPos = Vector(x_start_pos, y_end_pos, 0)
	local vEndPos = Vector(x_end_pos, y_end_pos, 0)
	local search_width = step_radius*math.sqrt(2)

	y_current_pos = y_current_pos + step_radius
--		local search_width = (self.pfx_top_right.y - self.pfx_bot_right.y)/2

	local teams = DOTA_UNIT_TARGET_TEAM_BOTH
	local types = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE

	local units = FindUnitsInLine(parent:GetTeam(), vStartPos, vEndPos, nil, search_width, teams, types, flags)
	
	for _,unit in pairs(units) do
		unit:AddNewModifier(parent, ability, "modifier_pubg_square_inside",{duration = self.tick_interval+0.1})
	end
end

modifier_pubg_square_inside = ({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
})

modifier_pubg_square_aura = ({
	IsHidden = function(self) return true end,
})

function modifier_pubg_square_aura:OnCreated()
	local ability = self:GetAbility()
	self.dmg_interval = ability:GetSpecialValueFor("dmg_interval")
	self.dmg_base = ability:GetSpecialValueFor("dmg_base")
	self.dmg_pct = ability:GetSpecialValueFor("dmg_pct")
 
 	self:StartIntervalThink(self.dmg_interval)
end

function modifier_pubg_square_aura:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local damage = (self.dmg_base + self.dmg_pct*parent:GetMaxHealth()/100)*self.dmg_interval

 	if not parent:HasModifier("modifier_pubg_square_inside") then
	 	local damage_table = {
	 		attacker = caster,
	 		victim = parent,
	 		damage = damage,
	 		damage_type = DAMAGE_TYPE_PURE,
	 		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
	 		ability = ability,
	 	}
	 	ApplyDamage(damage_table)
 	end
end
