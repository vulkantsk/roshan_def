--	Author: zimberzimber
--	Date:	19.2.2017

-- Attempt to implement A*-algorithm
-- https://github.com/lattejed/a-star-lua	


--CreateEmptyTalents("riki")
local LinkedModifiers = {}

---------------------------------------------------------------------
--------------------	Tricks of the Trade		---------------------
---------------------------------------------------------------------
if riki_tricks_of_the_trade_custom == nil then riki_tricks_of_the_trade_custom = class({}) end
LinkLuaModifier( "modifier_riki_tricks_of_the_trade_custom_primary", "heroes/hero_riki/tricks_of_the_trade_custom", LUA_MODIFIER_MOTION_NONE )		-- Hides the caster and damages all enemies in the AoE
LinkLuaModifier( "modifier_riki_tricks_of_the_trade_custom_secondary", "heroes/hero_riki/tricks_of_the_trade_custom", LUA_MODIFIER_MOTION_NONE )	-- Attacks a single enemy based on attack speed

function riki_tricks_of_the_trade_custom:GetAbilityTextureName()
   return "riki_tricks_of_the_trade"
end

function riki_tricks_of_the_trade_custom:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function riki_tricks_of_the_trade_custom:IsNetherWardStealable()
	return false
end

function riki_tricks_of_the_trade_custom:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

function riki_tricks_of_the_trade_custom:GetCastRange()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cast_range") end
		
	return self:GetSpecialValueFor("area_of_effect")
end

function riki_tricks_of_the_trade_custom:GetAOERadius()
	return self:GetSpecialValueFor("area_of_effect") end
	
function riki_tricks_of_the_trade_custom:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local origin = caster:GetAbsOrigin()
		local aoe = self:GetSpecialValueFor("area_of_effect")
		local target = self:GetCursorTarget()
		
		if caster:HasScepter() then
			origin = target:GetAbsOrigin() end
		
		caster:AddNewModifier(caster, self, "modifier_riki_tricks_of_the_trade_custom_primary", {})
		caster:AddNewModifier(caster, self, "modifier_riki_tricks_of_the_trade_custom_secondary", {})
			   
		local cast_particle = "particles/units/heroes/hero_riki/riki_tricks_cast.vpcf"
		local tricks_particle = "particles/units/heroes/hero_riki/riki_tricks.vpcf"
		local cast_sound = "Hero_Riki.TricksOfTheTrade.Cast"
		

		
		EmitSoundOnLocationWithCaster(origin, cast_sound, caster)
		EmitSoundOn(continuos_sound, caster)

		local caster_loc = caster:GetAbsOrigin()
		
		if caster:HasScepter() and target ~= caster then
			self.TricksParticle = ParticleManager:CreateParticle(tricks_particle, PATTACH_WORLDORIGIN, caster)
			

			ParticleManager:CreateParticle(cast_particle, PATTACH_WORLDORIGIN, nil)
		else
			self.TricksParticle = ParticleManager:CreateParticle(tricks_particle, PATTACH_WORLDORIGIN, caster)
			

			ParticleManager:CreateParticle(cast_particle, PATTACH_WORLDORIGIN, nil)
		end		
		
		ParticleManager:SetParticleControl(self.TricksParticle, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.TricksParticle, 1, Vector(aoe, 0, aoe))
		ParticleManager:SetParticleControl(self.TricksParticle, 2, Vector(aoe, 0, aoe))
		
		caster:AddNoDraw()
	end
end

function riki_tricks_of_the_trade_custom:OnChannelThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if caster:HasScepter() and target and target ~= caster then
			origin = target:GetAbsOrigin()
			caster:SetAbsOrigin(origin)
			ParticleManager:SetParticleControl(self.TricksParticle, 0, origin)
			ParticleManager:SetParticleControl(self.TricksParticle, 3, origin)
		end
	end
end

function riki_tricks_of_the_trade_custom:OnChannelFinish()
	if IsServer() then
		local caster = self:GetCaster()
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		caster:RemoveModifierByName("modifier_riki_tricks_of_the_trade_custom_primary")
		caster:RemoveModifierByName("modifier_riki_tricks_of_the_trade_custom_secondary")
	
		StopSoundEvent("Hero_Riki.TricksOfTheTrade", caster)
		ParticleManager:DestroyParticle(self.TricksParticle, false)
		ParticleManager:ReleaseParticleIndex(self.TricksParticle)
		self.TricksParticle = nil				
		
		local target = self:GetCursorTarget()
		caster:RemoveNoDraw()
		local end_particle = "particles/units/heroes/hero_riki/riki_tricks_end.vpcf"
		local particle = ParticleManager:CreateParticle(end_particle, PATTACH_ABSORIGIN, caster)
		ParticleManager:ReleaseParticleIndex(particle)
	end
end

----------------------------------------------
-----	Tricks of the Trade modifier	  ----
----------------------------------------------
if modifier_riki_tricks_of_the_trade_custom_primary == nil then modifier_riki_tricks_of_the_trade_custom_primary = class({}) end
function modifier_riki_tricks_of_the_trade_custom_primary:IsPurgable() return false end
function modifier_riki_tricks_of_the_trade_custom_primary:IsDebuff() return false end
function modifier_riki_tricks_of_the_trade_custom_primary:IsHidden() return false end

function modifier_riki_tricks_of_the_trade_custom_primary:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, }
	return funcs
end

function modifier_riki_tricks_of_the_trade_custom_primary:GetModifierAttackRangeBonus()
	local ability = self:GetAbility()
	local aoe = ability:GetSpecialValueFor("area_of_effect")
	return aoe
end

function modifier_riki_tricks_of_the_trade_custom_primary:CheckState()
	if IsServer() then
		local state
		
		if self:GetParent():HasScepter() and self:GetAbility():GetCursorTarget() == self:GetParent() then
			state = {	[MODIFIER_STATE_INVULNERABLE] = true,
					--	[MODIFIER_STATE_UNSELECTABLE] = true,		Temporary Solution to self-casting getting cancelled
					--	[MODIFIER_STATE_OUT_OF_GAME] = true,		Side effects - Caster will still be selectable with drag-box, and will interact with skillshots (like meat hook)
						[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
						[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
		else
			state = {	[MODIFIER_STATE_INVULNERABLE] = true,
						[MODIFIER_STATE_UNSELECTABLE] = true,
						[MODIFIER_STATE_OUT_OF_GAME] = true,
						[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
						[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
		end
			
		return state
	end
end

function modifier_riki_tricks_of_the_trade_custom_primary:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local interval = ability:GetSpecialValueFor("attack_interval") + self:GetCaster():FindTalentValue("special_bonus_imba_riki_7")
		self:StartIntervalThink(interval)
	end
end

function modifier_riki_tricks_of_the_trade_custom_primary:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
		local origin = caster:GetAbsOrigin()
		
		if caster:HasScepter() then
			local target = ability:GetCursorTarget()
			origin = target:GetAbsOrigin()
			caster:SetAbsOrigin(origin)
		end

		local aoe = ability:GetSpecialValueFor("area_of_effect")
		
	
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER , false)
		for _,unit in pairs(targets) do
			if unit:IsAlive() and not unit:IsAttackImmune() then
				caster:PerformAttack(unit, true, true, true, false, false, false, false)
											
			end
		end
	end
end

------------------------------------------------------
-----	Tricks of the Trade secondary attacks	  ----
------------------------------------------------------
if modifier_riki_tricks_of_the_trade_custom_secondary == nil then modifier_riki_tricks_of_the_trade_custom_secondary = class({}) end
function modifier_riki_tricks_of_the_trade_custom_secondary:IsPurgable() return false end
function modifier_riki_tricks_of_the_trade_custom_secondary:IsDebuff() return false end
function modifier_riki_tricks_of_the_trade_custom_secondary:IsHidden() return true end

function modifier_riki_tricks_of_the_trade_custom_secondary:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		local aps = parent:GetAttacksPerSecond()				
		if aps>=10 
			then	self:StartIntervalThink(0.1)			
			else	self:StartIntervalThink(1/aps)
		end
	end
end

function modifier_riki_tricks_of_the_trade_custom_secondary:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
		local origin = caster:GetAbsOrigin()
		
		if caster:HasScepter() then
			local target = ability:GetCursorTarget()
			origin = target:GetAbsOrigin()
			caster:SetAbsOrigin(origin)
		end

		local aoe =	 ability:GetSpecialValueFor("area_of_effect")
		
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER , false)
		for _,unit in pairs(targets) do
			if unit:IsAlive() and not unit:IsAttackImmune() then
				caster:PerformAttack(unit, true, true, true, false, false, false, false)
			
				local aps = caster:GetAttacksPerSecond()				
				self:StartIntervalThink(1/aps)				
				return
			end
		end
	end
end
-------------------------------------------
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
	LinkLuaModifier(LinkedModifier, "heroes/hero_riki/tricks_of_the_trade_custom", MotionController)
end
-------------------------------------------