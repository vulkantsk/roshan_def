LinkLuaModifier("modifier_meepo_dig_deeper", "heroes/hero_meepo/dig_deeper", LUA_MODIFIER_MOTION_NONE)


meepo_dig_deeper = meepo_dig_deeper or class ({})

function meepo_dig_deeper:GetCastRange()	
	return self:GetSpecialValueFor("cast_range")	
end

function meepo_dig_deeper:GetAOERadius()	
	return self:GetSpecialValueFor("tunnel_radius")	
end

function meepo_dig_deeper:GetChannelTime()	
	return self:GetSpecialValueFor("channel_time")	
end

function meepo_dig_deeper:OnSpellStart()
	local caster = self:GetCaster()	
	local caster_point = caster:GetAbsOrigin()	
	local target_point = self:GetCursorPosition()		
	caster:EmitSound("Hero_Meepo.Poof.Channel")

	local effect = "particles/units/heroes/hero_meepo/meepo_poof_start.vpcf"
	local pfx  = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, caster_point)
	ParticleManager:SetParticleControl(pfx, 1, caster_point)
	ParticleManager:ReleaseParticleIndex(pfx)

	local pfx  = ParticleManager:CreateParticle(effect, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, target_point)
	ParticleManager:SetParticleControl(pfx, 1, target_point)
	ParticleManager:ReleaseParticleIndex(pfx)

end

function meepo_dig_deeper:OnChannelFinish(bInterrupted)
	if IsServer() then
		if not bInterrupted then
			-- Ability properties
			local caster = self:GetCaster()	
			local ability = self
			local caster_fw = caster:GetForwardVector()	
			local caster_point = caster:GetAbsOrigin()	
			local target_point = self:GetCursorPosition()		
			local cast_response = "meepo_meepo_poof_0"..RandomInt(1, 8)
			local modifier_tunnel = "modifier_meepo_dig_deeper"
			local duration = ability:GetSpecialValueFor("tunnel_duration")	
			caster:EmitSound(cast_response)

			
			local tunnel_entry = CreateModifierThinker(caster, ability, modifier_tunnel, {duration = duration}, caster_point, caster:GetTeamNumber(), false)
			local tunnel_exit = CreateModifierThinker(caster, ability, modifier_tunnel, {duration = duration}, target_point, caster:GetTeamNumber(), false)
			tunnel_entry.tunnel = tunnel_exit
			tunnel_entry:SetForwardVector(-caster_fw)
			tunnel_exit.tunnel = tunnel_entry
			tunnel_exit:SetForwardVector(caster_fw)
		end
	end
end


---------------------------------------------------
--		Static Storm Modifier
---------------------------------------------------
modifier_meepo_dig_deeper = modifier_meepo_dig_deeper or class({})

function modifier_meepo_dig_deeper:IsHidden()	return true end
function modifier_meepo_dig_deeper:IsPassive()	return true end

function modifier_meepo_dig_deeper:OnCreated(keys)
	if IsServer() then
		Timers:CreateTimer(0, function()
			self.parent = self:GetParent()
			self.tunnel_exit = self.parent.tunnel
			self.radius = self:GetAbility():GetSpecialValueFor("tunnel_radius")
			self.self_point = self.parent:GetAbsOrigin()
			self.exit_point = self.tunnel_exit:GetAbsOrigin() + self.tunnel_exit:GetForwardVector()*(self.radius + 50)

			local pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/ti9_emblem_effect_ground_dark.vpcf", PATTACH_WORLDORIGIN, self.parent)
			ParticleManager:SetParticleControl(pfx, 0,self.self_point)
			self:AddParticle( pfx, false, false, -1, false, false )

			self:StartIntervalThink(0.1)
		end)
	end
end

function modifier_meepo_dig_deeper:OnIntervalThink()


	local allies = self.parent:FindFriendlyUnitsInRadius(self.self_point, self.radius, nil)

	for _,ally in pairs(allies) do
		if ally:IsControllableByAnyPlayer() then
			ally:EmitSound("Hero_Meepo.Poof")
			ally:Stop()
			FindClearSpaceForUnit(ally, self.exit_point, true)
		end
	end
		
end
