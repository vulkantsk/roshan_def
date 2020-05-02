ability_killer_3 = class({})
function ability_killer_3:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_ability_killer_3_delay', {
		duration = self:GetSpecialValueFor('delay')
	})
end

LinkLuaModifier("modifier_ability_killer_3_delay", 'abilities/killer/ability_killer_3.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_killer_3_debuff", 'abilities/killer/ability_killer_3.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_killer_3_delay = class({})

function modifier_ability_killer_3_delay:IsHidden() return false end
function modifier_ability_killer_3_delay:IsPurgable() return false end
function modifier_ability_killer_3_delay:IsDebuff() return true end
function modifier_ability_killer_3_delay:IsBuff() return false end
function modifier_ability_killer_3_delay:RemoveOnDeath() return true end
function modifier_ability_killer_3_delay:IsPermanent() return false end
function modifier_ability_killer_3_delay:OnDestroy()
	if IsClient() then return end
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), 'modifier_ability_killer_3_debuff', {
		duration = self:GetAbility():GetSpecialValueFor('duration')
	})

	local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge_finale.vpcf', PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(nfx, 3, Vector(2,2,2))
end

modifier_ability_killer_3_debuff = class({})
function modifier_ability_killer_3_debuff:IsHidden() return false end
function modifier_ability_killer_3_debuff:IsPurgable() return true end
function modifier_ability_killer_3_debuff:IsDebuff() return true end
function modifier_ability_killer_3_debuff:IsBuff() return false end
function modifier_ability_killer_3_debuff:RemoveOnDeath() return true end
function modifier_ability_killer_3_debuff:IsPermanent() return false end
function modifier_ability_killer_3_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_ability_killer_3_debuff:GetModifierPhysicalArmorBonus() return -self.armor end

function modifier_ability_killer_3_debuff:OnCreated()
	if IsClient() then return end
    self.armor = self:GetAbility():GetSpecialValueFor('remove_armor')
end

function modifier_ability_killer_3_debuff:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end