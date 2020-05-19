local path_to_file = 'heroes/hero_invoker/blink_icewall.lua' -- Если файл в корне
LinkLuaModifier('modifier_blink_icewall_unit',path_to_file,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_blink_icewall',path_to_file,LUA_MODIFIER_MOTION_NONE)

if not blink_icewall then
	blink_icewall = class({})
end
--Путь к этому файлу
function blink_icewall:OnSpellStart()
	local point = self:GetCursorPosition()
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local range = self:GetSpecialValueFor('blink_range')
	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end
	local placedis = self:GetSpecialValueFor('wall_place_distance')
	local num = self:GetSpecialValueFor('num_wall_elements')
	local space = self:GetSpecialValueFor('wall_element_spacing')
	caster:EmitSound("Hero_Invoker.IceWall.Cast")
	local direction = caster:GetForwardVector()
	target_point = casterPos + (direction * placedis)
	local direction_normal = Vector(-direction.y, direction.x, direction.z)
	local distance_from_center = (direction_normal * (num * space)) / 2
	local one_end_point = target_point - distance_from_center
	local ice_wall_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ice_wall_particle_effect, 0, target_point - distance_from_center)
	ParticleManager:SetParticleControl(ice_wall_particle_effect, 1, target_point + distance_from_center)
	local ice_wall_particle_effect_b = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_b.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ice_wall_particle_effect_b, 0, target_point - distance_from_center)
	ParticleManager:SetParticleControl(ice_wall_particle_effect_b, 1, target_point + distance_from_center)
	Timers(self:GetDuration(),function()
			ParticleManager:DestroyParticle(ice_wall_particle_effect, false)
			ParticleManager:DestroyParticle(ice_wall_particle_effect_b, false)
		end)
	caster:EmitSound('Hero_Antimage.Blink_out')
	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start_b.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(blinkIndex)
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(blinkIndex)
	caster:EmitSound('Hero_Antimage.Blink_in')
	for i=0,num do
		local ice_wall_unit = CreateUnitByName("npc_dummy_unit", one_end_point + direction_normal * (space * i), false, caster, caster, caster:GetTeamNumber())
		ice_wall_unit:AddNewModifier(caster,self,'modifier_blink_icewall_unit',{duration=self:GetDuration()})
	end
end

if not modifier_blink_icewall_unit then
	modifier_blink_icewall_unit=class({})
end
function modifier_blink_icewall_unit:IsHidden()
	return true
end
if IsServer() then
function modifier_blink_icewall_unit:OnCreated(t)
    self.ab = self:GetAbility()
    self:StartIntervalThink(0.1)
end
function modifier_blink_icewall_unit:OnIntervalThink()
  	return 0.1
end
function modifier_blink_icewall_unit:OnDestroy()
  	self:GetParent():ForceKill(false)
end
function modifier_blink_icewall_unit:IsAura()
    return true
end
function modifier_blink_icewall_unit:GetAuraRadius()
    return self.ab:GetSpecialValueFor('wall_element_radius')
end
function modifier_blink_icewall_unit:GetAuraDuration()
    return 0.1
end
function modifier_blink_icewall_unit:GetModifierAura()
    return "modifier_blink_icewall"
end
function modifier_blink_icewall_unit:GetAuraSearchTeam()
    return self.ab:GetAbilityTargetTeam()
end
function modifier_blink_icewall_unit:GetAuraSearchType()
    return self.ab:GetAbilityTargetType()
end
function modifier_blink_icewall_unit:GetAuraSearchFlags()
    return self.ab:GetAbilityTargetFlags()
end
end
function modifier_blink_icewall_unit:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
end
function modifier_blink_icewall_unit:CheckState()
    return {
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true
  }
end
function modifier_blink_icewall_unit:GetAbsoluteNoDamageMagical()
    return 1
end
function modifier_blink_icewall_unit:GetAbsoluteNoDamagePhysical()
    return 1
end
function modifier_blink_icewall_unit:GetAbsoluteNoDamagePure()
    return 1
end
function modifier_blink_icewall_unit:GetMinHealth()
    return 1
end
if not modifier_blink_icewall then
	modifier_blink_icewall=class({})
end
function modifier_blink_icewall:IsHidden()
    return false
end
function modifier_blink_icewall:GetTexture()
    return 'invoker_ice_wall'
end
function modifier_blink_icewall:IsDebuff()
    return true
end
function modifier_blink_icewall:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_blink_icewall:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('slow')
end
function modifier_blink_icewall:GetEffectName()
	return 'particles/units/heroes/hero_invoker/invoker_ice_wall_debuff.vpcf'
end
function modifier_blink_icewall:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
if IsServer() then
function modifier_blink_icewall:OnCreated(table)
	self.ab = self:GetAbility()
	self.caster = self:GetCaster()
	self.par = self:GetParent()
	self.damage = self.ab:GetSpecialValueFor('damage_per_second')
	self.interval = self.ab:GetSpecialValueFor('damage_interval')
    self:StartIntervalThink(self.interval)
end
function modifier_blink_icewall:OnIntervalThink()
	ApplyDamage({victim = self.par, attacker = self.caster, damage = self.damage, damage_type = self.ab:GetAbilityDamageType()})
	return self.interval
end
end