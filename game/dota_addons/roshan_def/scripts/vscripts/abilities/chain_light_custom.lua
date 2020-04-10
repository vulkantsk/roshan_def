LinkLuaModifier( "modifier_chain_light_custom", "abilities/chain_light_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chain_light_custom_thinker", "abilities/chain_light_custom", LUA_MODIFIER_MOTION_NONE )

chain_light_custom = class({})

function chain_light_custom:GetIntrinsicModifierName()
	return "modifier_chain_light_custom"
end

function chain_light_custom:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function chain_light_custom:Spawn()
	self.thinkers = {}
end


function chain_light_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:EmitSound("Item.Maelstrom.Chain_Lightning")

	local thinker = CreateModifierThinker(caster, self, "modifier_chain_light_custom_thinker", nil, caster:GetAbsOrigin(), caster:GetTeam(), false)
	thinker.id = thinker:entindex()
	table.insert(self.thinkers, thinker.id, thinker)
	local thinker_modifier = thinker:FindModifierByName("modifier_chain_light_custom_thinker")
	thinker_modifier:ChainLight(caster, target)
end

modifier_chain_light_custom = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}end,
})

function modifier_chain_light_custom:OnAttackLanded(data)
	local caster = self:GetCaster()
	local target = data.target
	local attacker = data.attacker

	if attacker == caster and not target:IsBuilding() and not target:IsMagicImmune() then
		local ability = self:GetAbility()
		local trigger_chance = ability:GetSpecialValueFor("trigger_chance")

		if RollPercentage(trigger_chance) then
			caster:EmitSound("Item.Maelstrom.Chain_Lightning")

			local thinker = CreateModifierThinker(caster, ability, "modifier_chain_light_custom_thinker", nil, caster:GetAbsOrigin(), caster:GetTeam(), false)
			thinker.id = thinker:entindex()
			table.insert(ability.thinkers, thinker.id, thinker)
			local thinker_modifier = thinker:FindModifierByName("modifier_chain_light_custom_thinker")
			thinker_modifier:ChainLightAlt(caster, target)
		end
	end
end

modifier_chain_light_custom_thinker = class({})

function modifier_chain_light_custom_thinker:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.bounce_damage = 	self.ability:GetSpecialValueFor("bounce_damage")
	self.bounce_radius = 	self.ability:GetSpecialValueFor("bounce_radius")
	self.bounce_interval = 	self.ability:GetSpecialValueFor("bounce_interval")
	self.bounce_count = 	self.ability:GetSpecialValueFor("bounce_count")
	
	self.target_count = 0
	self.bounced_targets = {}
end
function modifier_chain_light_custom_thinker:OnDestroy()
	table.remove(self.ability.thinkers, self.parent:entindex())
end

function modifier_chain_light_custom_thinker:ChainLight(target1, target2)
	self.bounced_targets[target2:entindex()] = true
	self.target_count = self.target_count + 1

	target2:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
--	ZapThem(caster, ability, caster, target, damage)

	local particle = "particles/items_fx/chain_lightning.vpcf"
--	if ability:GetAbilityName() == "item_imba_jarnbjorn" then
--		particle = "particles/items_fx/chain_lightning_jarnbjorn.vpcf"
--	end

	local bounce_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target1)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 0, target1, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 1, target2, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(bounce_pfx, 2, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(bounce_pfx)

	ApplyDamage({
		attacker = self.caster, 
		victim = target2, 
		ability = self.ability, 
		damage = self.bounce_damage, 
		damage_type = DAMAGE_TYPE_MAGICAL})

	Timers:CreateTimer(self.bounce_interval, function()
		self.trigger = false
		if self.target_count >= self.bounce_count then
			self:Destroy()
			return
		end

		local nearby_enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), 
					target2:GetAbsOrigin(), 
					nil, 
					self.bounce_radius, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
					FIND_ANY_ORDER, 
					false)

		for _, enemy in pairs(nearby_enemies) do
			local enemy_index = enemy:entindex()
			if self.bounced_targets[enemy_index] == nil then
				self:ChainLight(target2, enemy)
				self.trigger = true
				break
			end
		end

		if self.trigger == false then
			self:Destroy()
		end
	end)
end

function modifier_chain_light_custom_thinker:ChainLightAlt(target1, target2)
	self.bounced_targets[target2:entindex()] = true
	self.target_count = self.target_count + 1

	target2:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
--	ZapThem(caster, ability, caster, target, damage)

--	local particle = "particles/items_fx/chain_lightning.vpcf"
	local particle = "particles/econ/events/ti7/maelstorm_ti7.vpcf"
--	if ability:GetAbilityName() == "item_imba_jarnbjorn" then
--		particle = "particles/items_fx/chain_lightning_jarnbjorn.vpcf"
--	end

	local bounce_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target1)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 0, target1, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 1, target2, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(bounce_pfx, 2, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(bounce_pfx)

	ApplyDamage({
		attacker = self.caster, 
		victim = target2, 
		ability = self.ability, 
		damage = self.bounce_damage, 
		damage_type = DAMAGE_TYPE_MAGICAL})

	Timers:CreateTimer(self.bounce_interval, function()
		self.trigger = false
		if self.target_count >= self.bounce_count then
			self:Destroy()
			return
		end

		local nearby_enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), 
					target2:GetAbsOrigin(), 
					nil, 
					self.bounce_radius, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
					FIND_ANY_ORDER, 
					false)

		for _, enemy in pairs(nearby_enemies) do
			local enemy_index = enemy:entindex()
			if enemy ~= target2 then
				self:ChainLightAlt(target2, enemy)
				self.trigger = true
				break
			end
		end

		if self.trigger == false then
			self:Destroy()
		end
	end)
end
