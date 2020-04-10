LinkLuaModifier("modifier_centaur_double_edge_custom", "heroes/hero_centaur/double_edge_custom", LUA_MODIFIER_MOTION_NONE)


centaur_double_edge_custom = class({})

function centaur_double_edge_custom:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier( caster, self, "modifier_centaur_double_edge_custom", nil )
	else
		caster:RemoveModifierByName("modifier_centaur_double_edge_custom")
	end
end

modifier_centaur_double_edge_custom = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}end,
})

function modifier_centaur_double_edge_custom:OnAttackLanded(data)
	local caster = self:GetCaster()
	local target = data.target
	local attacker = data.attacker
	local ability = self:GetAbility()

	if caster == attacker and not target:IsBuilding() then	
		local current_mana  = caster:GetMana()
		local mana_required = ability:GetManaCost(-1)

		if current_mana > mana_required then
			local radius = ability:GetSpecialValueFor("radius")
			local base_dmg = ability:GetSpecialValueFor("base_dmg")
			local str_dmg = ability:GetSpecialValueFor("str_dmg")/100
			local damage = caster:GetStrength() * str_dmg + base_dmg
				
			caster:SetMana(current_mana - mana_required)
			EmitSoundOn("Hero_Centaur.DoubleEdge",target)
			
			local effect = "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf"
			local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin()) -- Origin
			ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin()) -- Destination
			ParticleManager:SetParticleControl(pfx, 5, target:GetAbsOrigin()) -- Hit Glow
			DealDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
	--[[
					local enemies = FindUnitsInRadius(caster:GetTeam(), 
													target:GetAbsOrigin(), 
													nil, 
													radius, 
													DOTA_UNIT_TARGET_TEAM_ENEMY, 
													DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
													DOTA_UNIT_TARGET_FLAG_NONE, 
													FIND_ANY_ORDER, false)
					
					for i=1,#enemies do
						local enemy = enemies[i]
						DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)		
					end
			]]		
		else
			ability:ToggleAbility()
		end
	end
end