invoker_wex_tornado = class({})


LinkLuaModifier('modifier_invoker_wex_tornado_debuff', 'heroes/hero_invoker/invoker_wex_tornado', LUA_MODIFIER_MOTION_NONE)

function invoker_wex_tornado:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Hero_Invoker.Tornado.Cast")
    self:GetCaster():StartGesture(ACT_DOTA_CAST_TORNADO)
    return true
end

function invoker_wex_tornado:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_TORNADO)
end

function invoker_wex_tornado:OnSpellStart()

    local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
    vDirection.z = 0.0
    vDirection = vDirection:Normalized()
    self:GetCaster():EmitSound("Hero_Invoker.Tornado")
    self:GetCaster():EmitSound("invoker_invo_ability_tornado_0" .. RandomInt(1,5))
    ProjectileManager:CreateLinearProjectile({
        EffectName = 'particles/econ/items/invoker/invoker_ti6/invoker_tornado_ti6.vpcf',
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius =self:GetSpecialValueFor('radius'),
		fEndRadius = self:GetSpecialValueFor('radius'),
		vVelocity = vDirection * self:GetSpecialValueFor('speed'),
		fDistance = self:GetSpecialValueFor('range'),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    })
end 

function invoker_wex_tornado:OnProjectileHit(hTarget, vLocation)
    if not hTarget then return end


    hTarget:AddNewModifier(self:GetCaster(), self, 'modifier_invoker_wex_tornado_debuff', {
        duration = self:GetSpecialValueFor('fly_duration')
    })

    local position = hTarget:GetOrigin()

    hTarget:AddNewModifier(self:GetCaster(), self, "modifier_knockback", {
		center_x = position.x,
		center_y = position.y,
		center_z = position.z,
		should_stun = 0,
		duration = self:GetSpecialValueFor('fly_duration'),
		knockback_duration = self:GetSpecialValueFor('fly_duration'),
		knockback_distance = 0,
		knockback_height = 600,
	})
end

modifier_invoker_wex_tornado_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    GetEffectName           = function(self) return 'particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf' end,
    GetEffectAttachType     = function(self) return 'attach_origin' end,
    CheckState              = function(self)
        return {
            [MODIFIER_STATE_FLYING] = true,		
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_STUNNED] = true,			
            [MODIFIER_STATE_ROOTED] = true,		
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,	
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        }
    end,
})

function modifier_invoker_wex_tornado_debuff:OnCreated()
    if IsClient() then return end

    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.__duration = self:GetDuration()


    local ideal_degrees_per_second = 666.666
    local ideal_full_spins = (ideal_degrees_per_second / 360) * self.__duration
    ideal_full_spins = math.floor(ideal_full_spins + 0.5) 
    local degrees_per_second_ending_in_same_forward_vector = (360 * ideal_full_spins) / self.__duration
    self.tornado_degrees_to_spin = degrees_per_second_ending_in_same_forward_vector * 0.03

    self.nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf', PATTACH_ABSORIGIN, self.parent)

    self:StartIntervalThink(0.03)
end 

function modifier_invoker_wex_tornado_debuff:OnDestroy() 
    if IsClient() then return end   	
    
    ParticleManager:DestroyParticle(self.nfx, false)
    ParticleManager:ReleaseParticleIndex(self.nfx)

    ApplyDamage({
        victim = self.parent,
        attacker = self.caster,
        damage = self.ability:GetSpecialValueFor('damage'),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability,  
    })

end

function modifier_invoker_wex_tornado_debuff:OnIntervalThink() 
    if IsClient() then return end   	
    self.parent:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0, self.tornado_degrees_to_spin, 0), self.parent:GetForwardVector()))

end