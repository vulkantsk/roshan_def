
if not invoker_invoke_custom then
	invoker_invoke_custom = class({})
end

local abilitiesInvoker = {
	[1] = {
		orb_particle = "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf",
		abilities={
			[1] = 'invoker_exort_sunstrikes',
			[2] = 'invoker_exort_fire_enchant',
			[3] = 'invoker_exort_forged_spirit',
			[6] = 'invoker_exort_chaos_meteor',
		},
	},
	[2] = {
		orb_particle = "particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf",
		abilities = {
			[1] = 'invoker_wex_tornado',
			[2] = 'invoker_wex_alacrity',
			[3] = 'invoker_wex_tempest_spirit',
			[6] = 'invoker_wex_wind_walk',
		},
	},
	[3] = {
		orb_particle = "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf",
		abilities = {
		[1] = 'invoker_quas_ice_wall',
		[2] = 'invoker_quas_water_shield',
		[3] = 'invoker_quas_water_spirit',
		[6] = 'invoker_quas_cold_snap',
		},
	},
}

function invoker_invoke_custom:Spawn()
	Timers:CreateTimer(0,function()
		self:OnSpellStart()
	end)
end 

function invoker_invoke_custom:OnSpellStart()
	local caster = self:GetCaster()
    local random_int = RandomInt(1,17)
    if random_int < 10 then
    	random_int = "0"..random_int
    end
    caster:EmitSound("invoker_invo_ability_invoke_" .. random_int)
    caster:EmitSound("Hero_Invoker.Invoke")

	if not self.form then
		self.form = 1
		self.orbs={}
	elseif self.form == 3 then
		self.form = 1
	else
		self.form = self.form + 1
	end

 
	for i=1,3 do
		local pfx = self.orbs[i]
		if pfx then
			ParticleManager:DestroyParticle(pfx, true)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
		local orb_particle = abilitiesInvoker[self.form].orb_particle
		local orb_pfx = ParticleManager:CreateParticle(orb_particle, PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(orb_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_orb" .. i, caster:GetAbsOrigin(), false)
		self.orbs[i] = orb_pfx	
	end

	for index,abilityName in pairs(abilitiesInvoker[self.form].abilities) do 
		local abilityByIndex = caster:GetAbilityByIndex(index - 1)
		if abilityByIndex then 
			caster:SwapAbilities(abilityByIndex:GetAbilityName(), abilityName, false, true)
		end
	end 
	if caster:HasModifier("modifier_item_special_invoker") then
		local ability_name = ""
		if self.buff_modifier then
			caster:RemoveModifierByName(self.buff_modifier)
		end
		if self.form == 1 then
			ability_name = "invoker_exort_fire_enchant"
			self.buff_modifier = "modifier_invoker_exort_fire_enchant_buff"
		elseif self.form == 2 then
			ability_name = "invoker_wex_alacrity"
			self.buff_modifier = "modifeir_invoker_wex_alacrity_buff"
		elseif self.form == 3 then
			ability_name = "invoker_quas_water_shield"
			self.buff_modifier = "modifier_invoker_quas_water_shield_buff"
		end
		caster:SetCursorCastTarget(caster)
		local buff_ability = caster:FindAbilityByName(ability_name)
		buff_ability:OnSpellStart()
		local modifier = caster:AddNewModifier(caster, buff_ability, self.buff_modifier, {duration = -1})
	elseif caster:HasModifier("modifier_item_special_invoker_upgrade") then
		caster:SetCursorCastTarget(caster)
		local buff_ability = caster:FindAbilityByName("invoker_wex_alacrity")
		buff_ability:OnSpellStart()
		local modifier = caster:AddNewModifier(caster, buff_ability, "modifeir_invoker_wex_alacrity_buff", {duration = -1})	
		local buff_ability = caster:FindAbilityByName("invoker_exort_fire_enchant")
		buff_ability:OnSpellStart()
		local modifier = caster:AddNewModifier(caster, buff_ability, "modifier_invoker_exort_fire_enchant_buff", {duration = -1})	
		local buff_ability = caster:FindAbilityByName("invoker_quas_water_shield")
		buff_ability:OnSpellStart()
		local modifier = caster:AddNewModifier(caster, buff_ability, "modifier_invoker_quas_water_shield_buff", {duration = -1})			
	end

end
