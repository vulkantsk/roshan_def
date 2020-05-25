LinkLuaModifier("modifier_invoker_wex_tempest_spirit_aura", "heroes/hero_invoker/invoker_wex_tempest_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_wex_tempest_spirit_debuff", "heroes/hero_invoker/invoker_wex_tempest_spirit", LUA_MODIFIER_MOTION_NONE)

invoker_wex_tempest_spirit = class({})

function invoker_wex_tempest_spirit:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function invoker_wex_tempest_spirit:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration_life = self:GetSpecialValueFor('duration')
   
    local unit = CreateUnitByName('npc_dota_invoker_tornado_custom', point, true, caster, caster, caster:GetTeam())

    unit:AddNewModifier(caster, self, 'modifier_kill', {
        duration = duration_life,
    })
    unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)

    unit:AddNewModifier(caster, self, 'modifier_invoker_wex_tempest_spirit_aura', {
        radius = self:GetSpecialValueFor('radius'),
        duration = duration_life,
    })

    caster:StartGesture(ACT_DOTA_CAST_ALACRITY)
    caster:EmitSound("Hero_Invoker.Tornado.Cast")

end

modifier_invoker_wex_tempest_spirit_aura = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,

	IsAura                  = function() return true end,
	GetModifierAura         = function() return "modifier_invoker_wex_tempest_spirit_debuff" end,
	GetAuraSearchTeam       = function() return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType       = function() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
	GetAuraSearchFlags      = function() return DOTA_UNIT_TARGET_FLAG_NONE end,
    GetAuraRadius           = function(self) return self.radius end,

    CheckState              = function(self)
        return {
            [MODIFIER_STATE_INVULNERABLE] = true,	
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
            [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        }
    end,
})

function modifier_invoker_wex_tempest_spirit_aura:OnCreated(data)
    self.radius = data.radius
    if not self.nfx and IsServer() then 
        self.nfx = ParticleManager:CreateParticle('particles/neutral_fx/tornado_ambient.vpcf', PATTACH_ABSORIGIN, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
    end
end 

function modifier_invoker_wex_tempest_spirit_aura:OnDestroy(data)
    if self.nfx then 
        ParticleManager:DestroyParticle(self.nfx, true)
        ParticleManager:ReleaseParticleIndex(self.nfx)
        self.nfx = nil
    end 
end 

modifier_invoker_wex_tempest_spirit_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end, 
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
        }
    end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self.slow end,
})

function modifier_invoker_wex_tempest_spirit_debuff:OnCreated()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    if not self.ability then return end
    self.damage_per_tick = self.ability:GetSpecialValueFor('dmg_per_tick')
    self.slow = self.ability:GetSpecialValueFor('slow')*(-1)
    self:StartIntervalThink(self.ability:GetSpecialValueFor('tick'))
end 

function modifier_invoker_wex_tempest_spirit_debuff:OnIntervalThink()
    if IsClient() then return end

    ApplyDamage({
        victim = self.parent,
        attacker = self.caster,
        damage = self.damage_per_tick,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability,
    })
end 

function modifier_invoker_wex_tempest_spirit_debuff:OnRefresh()
    self:OnCreated()
end     