LinkLuaModifier("modifier_treant_recover", "abilities/treant_recover", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_treant_recover_passive", "abilities/treant_recover", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_treant_recover_effect", "abilities/treant_recover", LUA_MODIFIER_MOTION_NONE)

treant_recover = class({})

function treant_recover:GetIntrinsicModifierName()
	return "modifier_treant_recover"
end

modifier_treant_recover = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
})

function modifier_treant_recover:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	caster:AddNewModifier(caster, ability, "modifier_treant_recover_passive", nil)
	caster:SetRenderColor(0, 128 , 0 )
end

modifier_treant_recover_passive = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    CheckState      = function(self) return 
        {
            [MODIFIER_STATE_ALLOW_PATHING_TROUGH_TREES] = true,
        }end,          
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_MIN_HEALTH,
            MODIFIER_EVENT_ON_TAKEDAMAGE
        } end,

})
function modifier_treant_recover_passive:GetMinHealth()
      return 1
end

function modifier_treant_recover_passive:OnTakeDamage( keys )
    if not  IsServer() then
        return
    end
    if keys.unit ~= self:GetCaster() then
        return
    end
 
    if self:GetCaster():GetHealth() <= 1 then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local recover_duration = ability:GetSpecialValueFor("recover_duration")
        
        caster:AddNewModifier(caster, ability, "modifier_treant_recover_effect", { duration = recover_duration})  
    end
end

modifier_treant_recover_effect = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
      	    MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_MODEL_CHANGE,
         } end,
    CheckState      = function(self) return 
        {
            [MODIFIER_STATE_UNSELECTABLE] = true,          
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,          
            [MODIFIER_STATE_INVULNERABLE] = true, 
            [MODIFIER_STATE_MAGIC_IMMUNE] = true, 
            [MODIFIER_STATE_STUNNED] = true, 
            [MODIFIER_STATE_ROOTED] = true, 
        } end,
})

function modifier_treant_recover_effect:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local model =  "models/props_tree/dire_tree003.vmdl"

		self.regen = 100/self:GetAbility():GetSpecialValueFor("recover_duration")

--		caster:SetRenderColor(255, 0 , 0 )

		caster:EmitSound("Hero_Treant.Overgrowth.Cast")	
	end
end

function modifier_treant_recover_effect:GetModifierModelChange()
	return "models/props_tree/dire_tree003.vmdl"
end

function modifier_treant_recover_effect:GetModifierModelScale()
    return 50--self:GetStackCount()
end

function modifier_treant_recover_effect:GetModifierHealthRegenPercentage()
    return self.regen
end

function modifier_treant_recover_effect:GetEffectName()
    return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end
