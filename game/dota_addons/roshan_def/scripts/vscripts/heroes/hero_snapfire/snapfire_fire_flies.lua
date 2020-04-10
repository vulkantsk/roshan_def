snapfire_fire_flies = class({
	OnSpellStart = function(self)
		local vPos = self:GetCursorPosition()
		local caster = self:GetCaster()
		self.hDummy = CreateUnitByName("npc_dummy_unit", vPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
		self.hDummy:AddNewModifier(caster, self, 'modifier_invulnerable', {duration = -1})
		ProjectileManager:CreateTrackingProjectile({
			Target = self.hDummy,
			Source = caster,
			Ability = self,
			EffectName = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare.vpcf",
			bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = 1200,
			iVisionRadius = 250,
			iVisionTeamNumber = caster:GetTeamNumber(),
		})
	end,
	OnProjectileHit 	= function( self,hTarget, vLocation )
	if hTarget and self.hDummy == hTarget then
		local modifier = CreateModifierThinker(
			self:GetCaster(), 
			self, 
			'modifier_fire_flies_aura', 
			{
				duration = self:GetSpecialValueFor('duration')
			}, 
			hTarget:GetAbsOrigin(), 
			self:GetCaster():GetTeamNumber(), 
			false)
		hTarget:ForceKill(false)
	end
end
})
LinkLuaModifier('modifier_fire_flies_aura', 'heroes/snapfire/snapfire_fire_flies', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_fire_flies_debuffs_stucks', 'heroes/snapfire/snapfire_fire_flies', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_fire_flies_debuffs_damage', 'heroes/snapfire/snapfire_fire_flies', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_fire_flies_buff', 'heroes/snapfire/snapfire_fire_flies', LUA_MODIFIER_MOTION_NONE)

modifier_fire_flies_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    IsPermanent             = function(self) return true end,
    IsAura                  = function(self) return true end,
    GetAuraRadius           = function(self) return self.radius end,
    GetAuraSearchTeam       = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
    GetAuraSearchFlags      = function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
    GetAuraSearchType       = function(self) return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end,
    GetModifierAura         = function(self) return 'modifier_fire_flies_buff' end,
    OnCreated               = function(self)
        if IsServer() then
            self.radius = self:GetAbility():GetSpecialValueFor('buff_radius')
            self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
			ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.nfx, 2, Vector(self.radius + 100,self.radius + 100,self.radius+ 100))
        	ParticleManager:SetParticleControl(self.nfx, 60, Vector(255,255,255))
        	ParticleManager:SetParticleControl(self.nfx, 61, Vector(2,2,2))
        end
    end,
    OnDestroy 	= function(self)
    	if IsClient() or not self.nfx then return end
    	ParticleManager:DestroyParticle( self.nfx, false);
    	ParticleManager:ReleaseParticleIndex( self.nfx );
    end,
})
modifier_fire_flies_debuffs_stucks = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
	GetEffectAttachType 	= function(self) return PATTACH_ABSORIGIN end,
	GetEffectName 			= function(self) return 'particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf' end,
})

modifier_fire_flies_debuffs_damage = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    GetAttributes 			= function(self) return {MODIFIER_ATTRIBUTE_MULTIPLE} end,
    OnCreated 				= function(self,kv) 
    	if IsClient() then return end
    	self.ability = self:GetAbility()
    	self.caster = self:GetCaster()
    	self.parent = self:GetParent()
    	self.damage = self.ability:GetSpecialValueFor('damage_per_tick')
    	self:StartIntervalThink(1)
   	end,
   	OnIntervalThink 		= function(self)
   		if IsServer() then 
   			ApplyDamage({
 				attacker = self.caster,
 				victim = self.parent,
 				damage = self.damage,
 				damage_type = DAMAGE_TYPE_MAGICAL,
 				ability = self.ability,
   			})	
   		end
   	end,
   	OnDestroy 	= function(self)
   		if IsClient() or not self.parent:HasModifier('modifier_fire_flies_debuffs_stucks') then return end
   		self.parent:AddStackModifier({
			ability = self.ability,
			modifier = 'modifier_fire_flies_debuffs_stucks',
			count = -1,
			caster = self.parent,
    	})
   	end,
})

modifier_fire_flies_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    OnCreated 				= function(self) 
    	if IsClient() then return  end

    	self.parent = self:GetParent()
    	self.caster = self:GetCaster()
    	self.ability = self:GetAbility()
        self.chance_critical = self.ability:GetSpecialValueFor('chance_critical')  --  damage filter
        self.critical_damage = self.ability:GetSpecialValueFor('critical_damage') --  damage filter
    	self.duration_debuffs = self.ability:GetSpecialValueFor('duration_debuffs')
    end,
    DeclareFunctions 		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
    GetMagicalCriticalChance = function(self) return self.chance_critical end,
    GetMagicalCriticalDamage = function(self) return self.critical_damage end,
    OnAttackLanded 			= function(self,data)
    	if IsServer() and data.attacker == self.parent then
    		data.target:AddStackModifier({
				ability = self.ability,
				modifier = 'modifier_fire_flies_debuffs_stucks',
				duration = self.duration_debuffs,
				updateStack = true,
				caster = self.parent,
    		})
    		data.target:AddNewModifier(self.parent, self.ability, 'modifier_fire_flies_debuffs_damage', {
    			duration = self.duration_debuffs,
    		})
    	end
    end,
})