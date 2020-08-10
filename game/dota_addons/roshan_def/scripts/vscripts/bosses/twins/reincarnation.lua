LinkLuaModifier("modifier_twins_reincarnation_passive", "bosses/twins/reincarnation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_twins_reincarnation", "bosses/twins/reincarnation", LUA_MODIFIER_MOTION_NONE)

twins_reincarnation = class({})

function twins_reincarnation:Spawn()
	Timers:CreateTimer(0.1,function()
		local caster = self:GetCaster()
		local team = caster:GetTeam()
		local point = caster:GetAbsOrigin()
		local unit_name = "npc_dota_twins_2"

		self.units = {}
		caster:AddNewModifier(caster, self, "modifier_twins_reincarnation_passive", nil)
		table.insert(self.units, caster)

		for i=1,1 do
			local unit = CreateUnitByName(unit_name, point, true, nil, nil, team)
			unit:AddNewModifier(caster, self, "modifier_twins_reincarnation_passive", nil)
			table.insert(self.units, unit)
		end
	end)	
end

modifier_twins_reincarnation_passive = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	RemoveOnDeath = function(self) return true end,
	GetTexture = function(self) return "skeleton_king_reincarnation" end,
    DeclareFunctions        = function(self) return 
    {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    } end,
})

function modifier_twins_reincarnation_passive:OnCreated()
	local ability = self:GetAbility()
	self.bonus_dmg = ability:GetSpecialValueFor("bonus_dmg")
	self.bonus_as = ability:GetSpecialValueFor("bonus_as")
	if IsClient() then
		return
	end
	self.bonus_model = ability:GetSpecialValueFor("bonus_model")
	self.bonus_hp_pct = ability:GetSpecialValueFor("bonus_hp_pct")

end

---------------------------------------------------------
function modifier_twins_reincarnation_passive:GetMinHealth()
      return 1
end

function modifier_twins_reincarnation_passive:OnTakeDamage( keys )
    if not  IsServer() then
        return
    end
    local parent = self:GetParent()
    
    if keys.unit ~= parent then
        return
    end
 
    if parent:GetHealth() <= 1 then
        local ability = self:GetAbility()
        local recover_duration = ability:GetSpecialValueFor("recover_duration")
		EmitSoundOn( "Cavern.Reincarnate", parent )
		self:IncrementStackCount()

        parent:AddNewModifier(parent, ability, "modifier_twins_reincarnation", { duration = recover_duration})
        parent.killer = keys.attacker       
    end
end

function modifier_twins_reincarnation_passive:GetModifierExtraHealthPercentage()
	return self.bonus_hp_pct*self:GetStackCount()
end

function modifier_twins_reincarnation_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as*self:GetStackCount()
end


function modifier_twins_reincarnation_passive:GetModifierDamageOutgoing_Percentage()
	return self.bonus_dmg*self:GetStackCount()
end

modifier_twins_reincarnation = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	RemoveOnDeath = function(self) return true end,
	CheckState = function(self) return {
--		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY ] = true,
	}end,
	DeclareFunctions = function(self) return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}end,
})

function modifier_twins_reincarnation:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_twins_reincarnation:OnCreated(data)
	if IsClient() then
		return
	end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local recover_duration = ability:GetSpecialValueFor("recover_duration")
	self.animation_rate = 1
	self.regen = 100/recover_duration
	parent.wake = true

    local all_dead = true
    for _,unit in pairs(ability.units) do
    	if not unit.wake then
    		all_dead = false
    		break
    	end
    end
    if all_dead then
        for _,unit in pairs(ability.units) do
        	unit:RemoveModifierByName("modifier_twins_reincarnation_passive")
        	unit:RemoveModifierByName("modifier_twins_reincarnation")
        	unit:Kill(nil, parent.killer)
        end
    end	
end

function modifier_twins_reincarnation:OnDestroy()
	self:GetParent().wake = false
end

function modifier_twins_reincarnation:GetOverrideAnimation()
	return ACT_DOTA_SPAWN
end

-------------------------------------------------------------------------------

function modifier_twins_reincarnation:GetOverrideAnimationRate()
	return 0.07
end

function modifier_twins_reincarnation:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"--"particles/units/heroes/hero_skeletonking/wraith_king_ambient.vpcf"
end

function modifier_twins_reincarnation:GetModifierHealthRegenPercentage()
    return self.regen
end
