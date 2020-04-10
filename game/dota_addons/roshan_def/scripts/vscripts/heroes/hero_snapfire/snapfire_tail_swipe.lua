snapfire_tail_swipe = class({
	OnSpellStart = function(self)
		local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor('radius')
		local units = FindUnitsInRadius(caster:GetTeamNumber(), 
			caster:GetOrigin(), 
			nil, 
			radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER, 
			false)

		local dur_knock = self:GetSpecialValueFor('duration_knockback')
		local knockback_distance = self:GetSpecialValueFor('radius_knock')
		for k,v in pairs(units) do
			local vLocation = v:GetOrigin()
			ApplyDamage({
 				attacker = caster,
 				victim = v,
 				damage = self:GetSpecialValueFor('damage'),
 				damage_type = DAMAGE_TYPE_PURE,
 				ability = self,
			})
			if not v:IsRooted() and not v:IsTower() and v:GetMoveCapability() ~= DOTA_UNIT_CAP_MOVE_NONE then 
				v:AddNewModifier(caster, self, "modifier_snapfire_force",{ 
					duration = dur_knock,
					knockback_distance = knockback_distance / dur_knock,
				}) 
			end
		end
        local nfx = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() );
		ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
	end,
})
LinkLuaModifier('modifier_snapfire_force_kostil', 'heroes/snapfire/snapfire_tail_swipe', LUA_MODIFIER_MOTION_NONE)
modifier_snapfire_force_kostil = class({
	IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    AllowIllusionDuplicate  = function(self) return false end,
    IsPermanent 			= function(self) return true end,
    CheckState 				= function(self)
    	return {
    		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    	}
    end,
})

LinkLuaModifier('modifier_snapfire_force', 'heroes/snapfire/snapfire_tail_swipe', LUA_MODIFIER_MOTION_NONE)
modifier_snapfire_force = class({})

--------------------------------------------------------------------------------

function modifier_snapfire_force:GetEffectName()
	return "particles/items_fx/force_staff.vpcf"
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:GetStatusEffectName()
	return "particles/status_fx/status_effect_forcestaff.vpcf"
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:StatusEffectPriority()
	return 10
end

function modifier_snapfire_force:OnCreated( kv )
	if IsServer() then
		self.distance = kv.knockback_distance
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self:StartIntervalThink(0.03)
	end
end

function modifier_snapfire_force:OnIntervalThink()
	if IsServer() then
		local parent = self.parent
		local pos = parent:GetAbsOrigin()
		local caster = self.caster
		local kekw = parent:GetAbsOrigin() - caster:GetAbsOrigin()
		parent:SetAbsOrigin( pos + (1) * kekw:Normalized() * FrameTime() * self.distance )
	end
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_snapfire_force:OnDestroy()
	if IsClient() then return end
	if not self.parent:IsAlive() then return end

	self.parent:AddNewModifier(self.parent, self.ability, 'modifier_snapfire_force_kostil', {duration = 0.9})
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:OnDeath( params )
	if IsServer() then
		if params.unit == self:GetCaster() then
			self:Destroy()
		end
	end

	return 0
end

--------------------------------------------------------------------------------

function modifier_snapfire_force:CheckState()
	local state = 
	{
		[ MODIFIER_STATE_STUNNED ] = true,
		[ MODIFIER_STATE_INVULNERABLE ] = true,
		[ MODIFIER_STATE_OUT_OF_GAME ] = true,
	}

	return state
end
