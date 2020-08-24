LinkLuaModifier("modifier_pubg_square", "abilities/quest/pubg_square", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pubg_square_aura", "abilities/quest/pubg_square", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pubg_square_inside", "abilities/quest/pubg_square", LUA_MODIFIER_MOTION_NONE)

pubg_square = class({})

function pubg_square:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_pubg_square", nil)
	ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
--	ParticleManager:SetParticleControl(self.pfx_top, 0, self.pfx_top_a)
--	ParticleManager:SetParticleControl(self.pfx_top, 1, self.pfx_top_b)

end

function pubg_square:GetIntrinsicModifierName()
--	return "modifier_pubg_square"
end
--------------------------------------------------------
------------------------------------------------------------

modifier_pubg_square = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	IsAura = function(self) return true end,
	GetAuraRadius = function(self) return self.total_radius end,
	GetModifierAura = function(self) return "modifier_pubg_square_aura" end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
})

function modifier_pubg_square:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		self.total_radius	= ability:GetSpecialValueFor("total_radius")

		local start_point	= parent:GetAbsOrigin()+Vector(0, 0, 100)
		local start_width	= ability:GetSpecialValueFor("start_width")
		local start_height	= ability:GetSpecialValueFor("start_height")
		local half_width = start_width/2
		local half_height = start_height/2
		self.pfx_top_a = start_point + Vector(half_width,half_height,0)
		self.pfx_top_b = start_point + Vector(-half_width,half_height,0)

		self.pfx_bot_a = start_point + Vector(half_width,-half_height,0)
		self.pfx_bot_b = start_point + Vector(-half_width,-half_height,0)

		self.pfx_right_a = start_point + Vector(half_width,half_height,0)
		self.pfx_right_b = start_point + Vector(half_width,-half_height,0)

		self.pfx_left_a = start_point + Vector(-half_width,half_height,0)
		self.pfx_left_b = start_point + Vector(-half_width,-half_height,0)

		local speed_width	= ability:GetSpecialValueFor("speed_width")
		local speed_height	= ability:GetSpecialValueFor("speed_height")
		self.tick_interval 		= ability:GetSpecialValueFor("tick_interval")
		self.delta_width	= speed_width*self.tick_interval/2
		self.delta_height	= speed_height*self.tick_interval/2

--		local effect = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
--		local effect = "particles/units/heroes/hero_wisp/wisp_tether.vpcf"
		local effect = "particles/units/heroes/hero_wisp/wisp_tether_agh.vpcf"

		self.pfx_top = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_top, 0, self.pfx_top_a)
		ParticleManager:SetParticleControl(self.pfx_top, 1, self.pfx_top_b)

		self.pfx_bot = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_bot, 1, self.pfx_bot_b)
		ParticleManager:SetParticleControl(self.pfx_bot, 0, self.pfx_bot_a)

		self.pfx_left = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_left, 0, self.pfx_left_a)
		ParticleManager:SetParticleControl(self.pfx_left, 1, self.pfx_left_b)

		self.pfx_right = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx_right, 0, self.pfx_right_a)
		ParticleManager:SetParticleControl(self.pfx_right, 1, self.pfx_right_b)

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

--[[
	self.pfx_top_a = self.pfx_top_a + Vector(delta_width,delta_height,0)
	self.pfx_top_b = self.pfx_top_b + Vector(-delta_width,delta_height,0)

	self.pfx_bot_a = self.pfx_bot_a + Vector(delta_width,-delta_height,0)
	self.pfx_bot_b = self.pfx_bot_b + Vector(-delta_width,-delta_height,0)

	self.pfx_right_a = self.pfx_right_a + Vector(delta_width,delta_height,0)
	self.pfx_right_b = self.pfx_right_b + Vector(delta_width,-delta_height,0)

	self.pfx_left_a = self.pfx_left_a + Vector(-delta_width,delta_height,0)
	self.pfx_left_b = self.pfx_left_b + Vector(-delta_width,-delta_height,0)
	
	ParticleManager:SetParticleControl(self.pfx_top, 0, self.pfx_top_a)
	ParticleManager:SetParticleControl(self.pfx_top, 1, self.pfx_top_b)

	ParticleManager:SetParticleControl(self.pfx_bot, 0, self.pfx_bot_a)
	ParticleManager:SetParticleControl(self.pfx_bot, 1, self.pfx_bot_b)

	ParticleManager:SetParticleControl(self.pfx_left, 0, self.pfx_left_a)
	ParticleManager:SetParticleControl(self.pfx_left, 1, self.pfx_left_b)

	ParticleManager:SetParticleControl(self.pfx_right, 0, self.pfx_right_a)
	ParticleManager:SetParticleControl(self.pfx_right, 1, self.pfx_right_b)
]]
	
	local vStartPos = (self.pfx_left_a+ self.pfx_left_b)/2
	local vEndPos = (self.pfx_right_a + self.pfx_left_b)/2

	local search_width = 200--(self.pfx_right_a.y - self.pfx_right_b.y)/2
	print(vStartPos)
	print(vEndPos)
	print("search_width = "..search_width)
	local teams = DOTA_UNIT_TARGET_TEAM_BOTH
	local types = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE

	local units = FindUnitsInLine(parent:GetTeam(), vStartPos, vEndPos, nil, search_width, teams, types, flags)
	
	for _,unit in pairs(units) do
		unit:AddNewModifier(parent, ability, "modifier_pubg_square_inside",{duration = self.tick_interval+0.1})
		print("unit name = "..unit:GetUnitName())
	end	

end

modifier_pubg_square_inside = ({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
})

modifier_pubg_square_aura = ({
	IsHidden = function(self) return false end,
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
