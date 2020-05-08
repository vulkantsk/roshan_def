LinkLuaModifier("modifier_sans_shield", 'abilities/sans/sans_ultra_evasion.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_shield_counter", 'abilities/sans/sans_ultra_evasion.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_shield_trigger", 'abilities/sans/sans_ultra_evasion.lua', LUA_MODIFIER_MOTION_NONE)

backtrack_datadriven = class({})

function backtrack_datadriven:GetIntrinsicModifierName() return 'modifier_sans_shield' end 

modifier_sans_shield = class({
	IsHidden = function(self) return true end,
})


function modifier_sans_shield:OnCreated()
	if IsClient() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	local particle = ParticleManager:CreateParticle('particles/sans/attach_eyes_c.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_eye", caster:GetAbsOrigin(), true)

	caster:AddNewModifier(caster, ability, "modifier_sans_shield_counter", nil)
end

modifier_sans_shield_counter = class({
	IsHidden = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}end,
})

function modifier_sans_shield_counter:GetMinHealth()
	return 1
end

function modifier_sans_shield_counter:GetModifierIncomingDamage_Percentage()
	return -200
end

function modifier_sans_shield_counter:OnCreated()
	if IsClient() then return end
	local particle = ParticleManager:CreateParticle('particles/sans/attach_eyes_c.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eye", self:GetCaster():GetAbsOrigin(), true)

	local ability = self:GetAbility()
	self.damage_need = ability:GetSpecialValueFor('damage_need')
	self.proc_chance =  ability:GetSpecialValueFor('proc_chance')
	self.proc_chance =  ability:GetSpecialValueFor('tick_need')
	self.damageTick = 0
	self:SetStackCount( ability:GetSpecialValueFor('max_layers'))
end

function modifier_sans_shield_counter:OnTakeDamage(data)
	local unit = data.unit
	local caster = self:GetCaster()

	if caster == unit and not caster:HasModifier("modifier_sans_shield_trigger") then
		self.damageTick = self.damageTick + 1

		local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(nfx)

		if self.damageTick >= self.damage_need then
			self.damageTick = 0
			local stack_count = self:GetStackCount()
			if stack_count == 1 then
				self:Destroy()
			else
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_sans_shield_trigger", {duration = self:GetAbility():GetSpecialValueFor("shockwave_delay")})
				self:DecrementStackCount()
			end
		end
	end
end

modifier_sans_shield_trigger = class({
	IsHidden = function(self) return true end,
})

function modifier_sans_shield_trigger:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local shockwave_delay = ability:GetSpecialValueFor("shockwave_delay")
		self.shockwave_radius = ability:GetSpecialValueFor("shockwave_radius")
		self.shockwave_damage = ability:GetSpecialValueFor("shockwave_damage")
		self.timer = shockwave_delay + 0.5

		self:StartIntervalThink(0.5)

		self.origin = self:GetParent():GetAbsOrigin()

		local nfx = ParticleManager:CreateParticle('particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf', PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(nfx, 0, self.origin)
		ParticleManager:SetParticleControl(nfx, 1, Vector(self.shockwave_radius,0,0))
		ParticleManager:SetParticleControl(nfx, 2, Vector(shockwave_delay,0,1))
		ParticleManager:SetParticleControl(nfx, 3, Vector(0,0,200))
		ParticleManager:SetParticleControl(nfx, 4, Vector(0,0,0))
		ParticleManager:ReleaseParticleIndex(nfx)			
	end	
end

function modifier_sans_shield_trigger:OnDestroy()
	if IsClient() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local units = FindUnitsInRadius(caster:GetTeamNumber(),
	self.origin,
	nil,
	self.shockwave_radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	FIND_CLOSEST,
	false)

	for k,v in pairs(units) do

		ApplyDamage({
 			attacker = caster,
 			damage = self.shockwave_damage,
 			victim = v,
 			damage_type = DAMAGE_TYPE_PURE,
 			ability = ability,
		})
	end

	parent:EmitSound("Hero_Leshrac.Split_Earth.Tormented")
	local nfx = ParticleManager:CreateParticle('particles/alcore_my_own_hell.vpcf', PATTACH_WORLDORIGIN, parent)
	ParticleManager:SetParticleControl(nfx, 0, self.origin)
	ParticleManager:SetParticleControl(nfx, 1, Vector(self.shockwave_radius,self.shockwave_radius,self.shockwave_radius))
	ParticleManager:ReleaseParticleIndex(nfx)

	GridNav:DestroyTreesAroundPoint(self.origin,self.shockwave_radius,true)

end
function modifier_sans_shield_trigger:OnIntervalThink()
	self.timer = self.timer - 0.5

	local caster = self:GetCaster()
	local preSymbol = 0 -- Empty
	local digits = 2
	local integer = math.floor(math.abs(self.timer))
	local decimal = math.abs(self.timer) % 1

	if decimal < 0.5 then 
		decimal = 1 -- ".0"
	else 
		decimal = 8 -- ".5"
	end
--	print(integer,decimal)

	local effect = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl( pfx, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pfx, 1, Vector( preSymbol, integer, decimal) )
	ParticleManager:SetParticleControl( pfx, 2, Vector( digits, 0, 0) )

end

