LinkLuaModifier( "modifier_sniper_true_headshot", "heroes/hero_sniper/true_headshot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sniper_true_headshot_debuff", "heroes/hero_sniper/true_headshot", LUA_MODIFIER_MOTION_NONE )

sniper_true_headshot = class({})

function sniper_true_headshot:GetIntrinsicModifierName()
	return "modifier_sniper_true_headshot"
end

modifier_sniper_true_headshot = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
	 	{
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}end,
	
})


function modifier_sniper_true_headshot:OnAttackLanded(data)
	if IsServer() then
		-- When someone affected by overload buff has attacked
		local attacker = data.attacker
		local target = data.target
		if data.attacker == self:GetParent() and not target:IsBuilding() and target:GetTeamNumber() ~= data.attacker:GetTeamNumber() and not target:IsMagicImmune() then

			-- Ability properties
			local parent	=	self:GetParent()
			local ability	=	self:GetAbility()
			local point		=	parent:GetAbsOrigin()
			local particle	=	"particles/econ/items/sniper/sniper_immortal_cape_golden/sniper_immortal_cape_golden_headshot_slow.vpcf"
			-- Ability paramaters
			local knockback_dist =	ability:GetSpecialValueFor("knockback_dist") 
			local knockback_duration =	ability:GetSpecialValueFor("knockback_duration") 
			local proc_chance 	=	ability:GetSpecialValueFor("proc_chance") 
			local duration = self:GetSpecialValueFor("duration")
			local base_dmg = self:GetSpecialValueFor("base_dmg")
			local agi_dmg = self:GetSpecialValueFor("agi_dmg")*parent:GetAgility()/100
			local damage = base_dmg + agi_dmg


			if not RollPercentage(proc_chance) and not parent:HasModifier("modifier_item_special_mark_upgrade")  then
				return 
			end
			DealDamage(parent, target, damage, DAMAGE_TYPE_MAGICAL, nil, ability)
			target:EmitSound("Hero_Sniper.DuckTarget")

			target:AddNewModifier( parent, ability, "modifier_knockback", kv )
			local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(particle_fx)

			local kv = {
			should_stun = 0,
			knockback_duration = knockback_duration,
			duration = knockback_duration,
			knockback_distance = knockback_dist,
			knockback_height = 0,
			center_x = point.x,
			center_y = point.y,
			center_z = point.z
			}				
		end
	end
end

