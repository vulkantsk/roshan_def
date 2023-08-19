LinkLuaModifier("modifier_random_color", "abilities/random_color", LUA_MODIFIER_MOTION_NONE)

random_color = class({})

function random_color:GetIntrinsicModifierName()
	return "modifier_random_color"
end

modifier_random_color = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})
function modifier_random_color:OnCreated()
	if IsServer() then
		local change_interval = self:GetAbility():GetSpecialValueFor("change_interval")
		local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
		self.max_tick = math.floor(change_interval/tick_interval)

		self.r = 0
		self.g = 0
		self.b = 0

		self.tick_count = 0
		local new_r = RandomInt(0, 255)
		self.delta_r = (new_r - self.r)/ self.max_tick
		local new_g = RandomInt(0, 255)
		self.delta_g = (new_g - self.g)/ self.max_tick
		local new_b = RandomInt(0, 255)
		self.delta_b = (new_b - self.b)/ self.max_tick

		self:StartIntervalThink(tick_interval)
	end
end
--[[
		local new_r = RandomInt(0, 255)
		self.delta_r = new_r - self.r/ self.max_tick
		local new_g = RandomInt(0, 255)
		self.delta_g = new_g - self.g/ self.max_tick
		local new_b = RandomInt(0, 255)
		self.delta_b = new_b - self.b/ self.max_tick
]]
function modifier_random_color:OnIntervalThink()
	local caster = self:GetCaster()

	if self.tick_count == self.max_tick-1 then
		self.tick_count = 0
		local new_r = RandomInt(0, 255)
		self.delta_r = (new_r - self.r)/ self.max_tick
		local new_g = RandomInt(0, 255)
		self.delta_g = (new_g - self.g)/ self.max_tick
		local new_b = RandomInt(0, 255)
		self.delta_b = (new_b - self.b)/ self.max_tick
	else
		self.r = self.r + self.delta_r
		self.g = self.g + self.delta_g
		self.b = self.b + self.delta_b
		self.tick_count = self.tick_count + 1
	end

	caster:SetRenderColor(self.r, self.g , self.b )
--[[
	local number = self.red
	number = number + RandomInt(-5, 5)
	if number > 255 then
		number = 255
	elseif number == 0 then
		number = 0
	end
	self.red = number

	local number = self.green
	number = number + RandomInt(-5, 5)
	if number > 255 then
		number = 255
	elseif number == 0 then
		number = 0
	end
	self.green = number

	local number = self.blue
	number = number + RandomInt(-5, 5)
	if number > 255 then
		number = 255
	elseif number == 0 then
		number = 0
	end
	self.blue = number
	caster:SetRenderColor(self.red, self.green , self.blue )
]]
end

function randomize_color(render_c)
	local number = render_c
	number = number + RandomInt(-10, 10)
	if number > 255 then
		number = 255
	elseif number == 0 then
		number = 0
	end
	render_c = number
end
