
if not invoker_invoke_custom then
	invoker_invoke_custom = class({})
end
local abilitiesInvoker = {
	[1] = {
		'invoker_exort_sunstrikes',
		'invoker_exort_chaos_meteor',
		'invoker_exort_forged_spirit',
		'invoker_exort_fire_enchant',
	},
	[2] = {
		'invoker_wex_tornado',
		'invoker_wex_alacrity',
		'invoker_wex_tempest_spirit',
		'invoker_wex_wind_walk',
	},
	[3] = {
		'invoker_exort_sunstrikes',
		'invoker_exort_chaos_meteor',
		'invoker_exort_forged_spirit',
		'invoker_exort_fire_enchant',
	},
}
--Путь к этому файлу
function invoker_invoke_custom:OnSpellStart()
	local caster = self:GetCaster()

	if not self.form then
		self.form = 1
		self.orbs={}
	elseif self.form == 3 then
		self.form = 1
	else
		self.form = self.form + 1
	end

	caster:EmitSound("Hero_Invoker.Invoke")
	local orb_particle = ""
	
	if self.form == 1 then
		orb_particle = "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf"
	elseif self.form == 2 then
		orb_particle = "particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf"
	elseif self.form == 3 then
		orb_particle = "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf"
	end

	for formID,dataForm in pairs(abilitiesInvoker) do
		for  _,abilityName in pairs(dataForm) do 
			local ability = caster:FindAbilityByName(abilityName)
			if ability then 
				ability:SetHidden(formID ~= self.form)
				ability:SetLevel(7)
			end 
		end 
	end 

	for i=1,3 do
		local pfx = self.orbs[i]
		if pfx then
			ParticleManager:DestroyParticle(pfx, true)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
		local orb_pfx = ParticleManager:CreateParticle(orb_particle, PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(orb_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_orb" .. i, caster:GetAbsOrigin(), false)
		self.orbs[i] = orb_pfx
		
	end
end
