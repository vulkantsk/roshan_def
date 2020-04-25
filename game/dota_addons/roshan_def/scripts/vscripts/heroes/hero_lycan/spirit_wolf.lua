LinkLuaModifier("modifier_spirit_wolf", "heroes/hero_lycan/spirit_wolf", LUA_MODIFIER_MOTION_NONE)

lycan_spirit_wolf_custom = class({})

function lycan_spirit_wolf_custom:OnSpellStart()
	local caster = self:GetCaster()
	local player = caster:GetPlayerID()
	local ability = self
	local level = ability:GetLevel()
	local origin = caster:GetAbsOrigin() + RandomVector(100)

	local strenght = caster:GetStrength()
	local agility = caster:GetAgility()
	local intellegence = caster:GetIntellect()

	local base_hp = ability:GetSpecialValueFor("summon_hp")
	local base_hpreg = ability:GetSpecialValueFor("summon_hpreg")
	local base_dmg = ability:GetSpecialValueFor("summon_dmg")
	local base_armor = ability:GetSpecialValueFor("summon_armor")
	local dmg_per_strenght = ability:GetSpecialValueFor("dmg_per_str")
	local hp_per_strenght = ability:GetSpecialValueFor("hp_per_str")
	local model_scale = ability:GetSpecialValueFor("summon_scale")
	local fv = caster:GetForwardVector()
		-- Set the unit name, concatenated with the level number
	local unit_name = "npc_dota_spirit_wolf1"


	-- Check if the wolf is alive, heals and spawns them near the caster if it is
	if  caster.wolf and IsValidEntity(caster.wolf) and caster.wolf:IsAlive() then
		FindClearSpaceForUnit(caster.wolf, origin, true)
		local fv = caster:GetForwardVector()
		caster.wolf:SetForwardVector(fv)

		caster.wolf:SetBaseMaxHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetMaxHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetBaseHealthRegen(base_hpreg)
		caster.wolf:SetBaseDamageMin(base_dmg + strenght*dmg_per_strenght )
		caster.wolf:SetBaseDamageMax(base_dmg + strenght*dmg_per_strenght )				
		caster.wolf:SetPhysicalArmorBaseValue(base_armor)
		caster.wolf:SetModelScale(model_scale)
		-- Spawn particle
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.wolf)	
	elseif caster.wolf and IsValidEntity(caster.wolf) and not caster.wolf:IsAlive() then
		FindClearSpaceForUnit(caster.wolf, origin, true)
		local fv = caster:GetForwardVector()
		caster.wolf:SetForwardVector(fv)
		caster.wolf:RespawnUnit()
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.wolf)	
	else
		
----[[		
		if caster.wolf then 	
			local unit = caster.wolf
			item_table = {}
			for i = 0, 8 do
				local item = unit:GetItemInSlot( i )

				if item ~= nil then  		
					table.insert(item_table , item)
				end				
			end	
		end
--]]
		-- Create the unit and make it controllable
		caster.wolf = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.wolf:SetControllableByPlayer(player, true)
		caster.wolf:SetUnitCanRespawn(true)
		caster.wolf:SetForwardVector(fv)
	
		caster.wolf:SetBaseMaxHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetMaxHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetBaseHealthRegen(base_hpreg)
		caster.wolf:SetBaseDamageMin(base_dmg + strenght*dmg_per_strenght )
		caster.wolf:SetBaseDamageMax(base_dmg + strenght*dmg_per_strenght )				
		caster.wolf:SetPhysicalArmorBaseValue(base_armor)
		caster.wolf:SetModelScale(model_scale)

		SetLevelForSubAbility(ability, "lone_druid_spirit_bear_return", caster.wolf, 1, 1)
		SetLevelForSubAbility(ability, "lycan_summon_wolves_critical_strike", caster.wolf, 1, nil)
		SetLevelForSubAbility(ability, "lycan_summon_wolves_beowolf", caster.wolf, 6, 1)

		local items = item_table or {}
		for _,item in pairs(items) do	
			 caster.wolf:AddItem(item)
		 end
		-- Apply the backslash on death modifier
		if ability ~= nil then
			caster.wolf:AddNewModifier(caster, ability, "modifier_spirit_wolf", nil)
		end
	end

end

function lycan_spirit_wolf_custom:OnUpgrade()
	local caster = self:GetCaster()
	local player = caster:GetPlayerID()
	local ability = self
	local level = ability:GetLevel()
	local unit_name = "npc_dota_spirit_wolf1"



	if caster.wolf and caster.wolf:IsAlive() then 
		-- Remove the old wolf in its position
		local origin = caster.wolf:GetAbsOrigin()
		local health_pct = caster.wolf:GetHealthPercent()
		

		local strenght = caster:GetStrength()
		local agility = caster:GetAgility()
		local intellegence = caster:GetIntellect()

		local base_hp = ability:GetSpecialValueFor("summon_hp")
		local base_hpreg = ability:GetSpecialValueFor("summon_hpreg")
		local base_dmg = ability:GetSpecialValueFor("summon_dmg")
		local base_armor = ability:GetSpecialValueFor("summon_armor")
		local dmg_per_strenght = ability:GetSpecialValueFor("dmg_per_str")
		local hp_per_strenght = ability:GetSpecialValueFor("hp_per_str")
		local model_scale = ability:GetSpecialValueFor("summon_scale")
--		local fv = caster:GetForwardVector()
--		caster.wolf:SetForwardVector(fv)
		
		caster.wolf:SetBaseMaxHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetMaxHealth(base_hp + strenght*hp_per_strenght )
		caster.wolf:SetHealth(health_pct*caster.wolf:GetMaxHealth())
		caster.wolf:SetBaseHealthRegen(base_hpreg)
		caster.wolf:SetBaseDamageMin(base_dmg + strenght*dmg_per_strenght )
		caster.wolf:SetBaseDamageMax(base_dmg + strenght*dmg_per_strenght )				
		caster.wolf:SetPhysicalArmorBaseValue(base_armor)
		caster.wolf:SetModelScale(model_scale)

		SetLevelForSubAbility(ability, "lone_druid_spirit_bear_return", caster.wolf, 1, 1)
		SetLevelForSubAbility(ability, "lycan_summon_wolves_critical_strike", caster.wolf, 1, nil)
		SetLevelForSubAbility(ability, "lycan_summon_wolves_beowolf", caster.wolf, 6, 1)
		

		-- Apply the backslash on death modifier
		caster.wolf:AddNewModifier(caster, ability, "modifier_spirit_wolf", nil)

		-- Learn its abilities: return lvl 2, entangle lvl 3, demolish lvl 4. By Index
	end
end

-- Do a percentage of the caster health then the spawned unit takes fatal damage
function SpiritwolfDeath( event )
	local caster = event.caster
	local killer = event.attacker
	local ability = event.ability
	local casterHP = caster:GetMaxHealth()
	local backlash_damage = ability:GetLevelSpecialValueFor( "backlash_damage", ability:GetLevel() - 1 ) * 0.01

	-- Calculate and do the damage
	local damage = casterHP * backlash_damage

	ApplyDamage({ victim = caster, attacker = killer, damage = damage, damage_type = DAMAGE_TYPE_PURE })
end

modifier_spirit_wolf = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}end,
})

function modifier_spirit_wolf:OnCreated()
	local parent = self:GetParent()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)	

end
function modifier_spirit_wolf:OnDeath(data)
	local attacker = data.attacker
	local parent = self:GetParent()
	local unit = data.unit

	if unit == parent and attacker ~= parent then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local backlash_damage = ability:GetSpecialValueFor("backlash_damage")/100
		local damage = caster:GetMaxHealth()*backlash_damage
		print(attacker:GetUnitName())
		print(caster:GetUnitName())
		print(damage)

		DealDamage(attacker, caster, damage, DAMAGE_TYPE_PURE, nil, ability)
	end
end

function modifier_spirit_wolf:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("summon_bat")
end
