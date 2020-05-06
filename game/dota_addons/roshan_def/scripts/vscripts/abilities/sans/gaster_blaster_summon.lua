gaster_blaster_summon = class({})
function gaster_blaster_summon:GetIntrinsicModifierName() return 'sans_modifier_gaster_blaster_summon' end
function gaster_blaster_summon:OnSpellStart()
	local ability = self
	local caster = self:GetCaster()
	local radius = ability:GetSpecialValueFor('radius')
	local number_of_units = ability:GetSpecialValueFor('number_of_units')
	local duration = ability:GetSpecialValueFor('duration')
	local amount_creeps = ability:GetSpecialValueFor('amount_creeps')
	local origin = caster:GetOrigin()
	for index=1,amount_creeps do
		Timers:CreateTimer(1.5 * index,function()
			for i=1,number_of_units do
				local unit = CreateUnitByName('npc_dota_gaster_blaster', origin + RandomVector(RandomFloat(300,radius)), false, caster, caster, caster:GetTeam())
				unit:AddNewModifier(caster, self,  'modifier_kill', {
		            duration = duration,
				})
				local nfx = ParticleManager:CreateParticle('particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf', PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControl(nfx, 0, unit:GetOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)
			end
		end)
	end
end
LinkLuaModifier("sans_modifier_gaster_blaster_summon", 'abilities/sans/gaster_blaster_summon.lua', LUA_MODIFIER_MOTION_NONE)

sans_modifier_gaster_blaster_summon = class({})
function sans_modifier_gaster_blaster_summon:IsHidden() return true end

function sans_modifier_gaster_blaster_summon:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK } end
function sans_modifier_gaster_blaster_summon:OnCreated()
	if IsClient() then return end

	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.trigger_chance = self.ability:GetSpecialValueFor('trigger_chance')
	self.duration = self.ability:GetSpecialValueFor('duration')
	self.radius = self.ability:GetSpecialValueFor('radius')
end

function sans_modifier_gaster_blaster_summon:OnAttack(data)
	if IsClient() then return end
	if data.attacker ~= self.parent or not RollPercentage(self.trigger_chance) then return end
		local caster = self:GetCaster()
		local unit = CreateUnitByName('npc_dota_gaster_blaster', caster:GetOrigin() + RandomVector(RandomFloat(300,self.radius)), false, caster,caster, caster:GetTeam())
		unit:AddNewModifier(caster, self,  'modifier_kill', {
            duration = self.duration,
		})

		local nfx = ParticleManager:CreateParticle('particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf', PATTACH_ABSORIGIN_FOLLOW, unit)
		ParticleManager:SetParticleControl(nfx, 0, unit:GetOrigin())
		ParticleManager:ReleaseParticleIndex(nfx)

end