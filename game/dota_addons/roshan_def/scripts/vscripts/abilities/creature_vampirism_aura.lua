LinkLuaModifier("modifier_creature_vampirism_aura", "abilities/creature_vampirism_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_creature_vampirism_aura_effect", "abilities/creature_vampirism_aura", LUA_MODIFIER_MOTION_NONE)

creature_vampirism_aura = class({})

function creature_vampirism_aura:GetCastRAnge()
	return self:GetSpecialValueFor("aura_radius")
end

function creature_vampirism_aura:GetIntrinsicModifierName()
	return "modifier_creature_vampirism_aura"
end

modifier_creature_vampirism_aura = class({
	IsHidden 		= function(self) return true end,
	IsAura 			= function(self) return true end,
	GetAuraRadius 	= function(self) return self:GetAbility().aura_radius end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura   = function(self) return "modifier_creature_vampirism_aura_effect" end,
})

function modifier_creature_vampirism_aura:OnCreated( kv )
	local ability = self:GetAbility()

	ability.aura_radius = ability:GetSpecialValueFor( "aura_radius" )
	ability.vampiric_aura = ability:GetSpecialValueFor( "vampiric_aura" )/100
end

function modifier_creature_vampirism_aura:GetEffectName()
	return "particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_leaves_d.vpcf"
end
function modifier_creature_vampirism_aura:OnRefresh( kv )
	local ability = self:GetAbility()
	ability.vampiric_aura = ability:GetSpecialValueFor( "vampiric_aura" )/100
end

modifier_creature_vampirism_aura_effect = class({})

function modifier_creature_vampirism_aura_effect:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_creature_vampirism_aura_effect:OnTakeDamage( params )
	if IsServer() then
		local Target = params.unit
		local Attacker = params.attacker
		local ability = params.inflictor
		local flDamage = params.damage
		
		if Attacker ~= nil and Attacker == self:GetParent() and Target ~= nil and not Target:IsBuilding() and ability == nil then
			local heal =  flDamage * self:GetAbility().vampiric_aura
			Attacker:Heal( heal, self:GetAbility() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
	return 0
end

brotherhood_vampirism_aura = class(creature_vampirism_aura)