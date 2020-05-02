ability_midas_acolyte_2 = class({
	GetIntrinsicModifierName = function(self) return 'modifier_ability_midas_acolyte_2_aura' end,
})
LinkLuaModifier("modifier_ability_midas_acolyte_2_aura", 'abilities/midas_acolyte/ability_midas_acolyte_2.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_midas_acolyte_2_debuff", 'abilities/midas_acolyte/ability_midas_acolyte_2.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_midas_acolyte_2_aura = class({})

function modifier_ability_midas_acolyte_2_aura:IsHidden() return true end
function modifier_ability_midas_acolyte_2_aura:IsPurgable() return false end
function modifier_ability_midas_acolyte_2_aura:IsDebuff() return true end
function modifier_ability_midas_acolyte_2_aura:IsBuff() return false end
function modifier_ability_midas_acolyte_2_aura:RemoveOnDeath() return true end
function modifier_ability_midas_acolyte_2_aura:AllowIllusionDuplicate() return false end
function modifier_ability_midas_acolyte_2_aura:AllowIllusionDuplicate() return true end
function modifier_ability_midas_acolyte_2_aura:IsPermanent() return false end
function modifier_ability_midas_acolyte_2_aura:IsAura() return true end
function modifier_ability_midas_acolyte_2_aura:GetAuraRadius() return self.radius end
function modifier_ability_midas_acolyte_2_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_midas_acolyte_2_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_ability_midas_acolyte_2_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_midas_acolyte_2_aura:GetModifierAura() return 'modifier_ability_midas_acolyte_2_debuff' end
function modifier_ability_midas_acolyte_2_aura:GetAuraEntityReject(hEntity) return hEntity == self.parent end

function modifier_ability_midas_acolyte_2_aura:OnCreated() 
	if IsClient() then return end
	local ability = self:GetAbility()
	if not ability then return end
	self.parent = self:GetParent()
	self.radius = ability:GetLevelSpecialValueFor('aura_radius',1)
	self.parent.heal = ability:GetLevelSpecialValueFor('heal',1)
	self.parent.damage = ability:GetLevelSpecialValueFor('damage',1)
	self.parent.gold = ability:GetLevelSpecialValueFor('gold_lose',1)
end

modifier_ability_midas_acolyte_2_debuff = class({})

function modifier_ability_midas_acolyte_2_debuff:IsHidden() return false end
function modifier_ability_midas_acolyte_2_debuff:IsPurgable() return false end
function modifier_ability_midas_acolyte_2_debuff:IsDebuff() return true end
function modifier_ability_midas_acolyte_2_debuff:IsBuff() return false end
function modifier_ability_midas_acolyte_2_debuff:RemoveOnDeath() return true end
function modifier_ability_midas_acolyte_2_debuff:AllowIllusionDuplicate() return false end

function modifier_ability_midas_acolyte_2_debuff:OnCreated() 
	if IsClient() then return end
	local ability = self:GetAbility()
	self.ability = ability
	self.caster = self:GetCaster()
	local interval = ability:GetLevelSpecialValueFor('interval_tick',1)
	self:StartIntervalThink(interval)
end

function modifier_ability_midas_acolyte_2_debuff:OnIntervalThink() 
	if IsClient() or self.ability:IsNull() or not self.caster:IsAlive() or self.ability:GetLevel() < 1 then return end
	local parent = self:GetParent()
	local gold = parent:GetGold()
	local caster = self.caster
	if parent == caster then return end
	if caster.gold >= gold then return end

	ApplyDamage({
			victim = parent,
			attacker = caster,
			damage = caster.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability,
	})

	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	local goldBounty = caster:GetGoldBounty()
	caster:SetMaximumGoldBounty(goldBounty + caster.gold)
	caster:SetMinimumGoldBounty(goldBounty + caster.gold)

	parent:ModifyGold(-caster.gold, false, 0)
end