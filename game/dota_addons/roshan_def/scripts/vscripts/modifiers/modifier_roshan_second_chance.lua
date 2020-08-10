
modifier_roshan_second_chance = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_MIN_HEALTH,
            MODIFIER_EVENT_ON_TAKEDAMAGE
        } end,

})

function modifier_roshan_second_chance:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local model =  "models/props_tree/dire_tree003.vmdl"

        self.total_regen = 50
        self.recover_duration = 6
    end
end

function modifier_roshan_second_chance:GetTexture()
    return "item_aegis"
end

function modifier_roshan_second_chance:GetMinHealth()
      return 1
end

function modifier_roshan_second_chance:OnTakeDamage( keys )
    if not  IsServer() then
        return
    end
    local parent = self:GetParent()
    if keys.unit ~= parent then
        return
    end
 
    if self:GetCaster():GetHealth() <= 1 then  
        parent:AddNewModifier(parent, nil, "modifier_roshan_second_chance_effect", { duration = self.recover_duration, total_regen = self.total_regen})  
        self:Destroy()
    end
end

modifier_roshan_second_chance_effect = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
      	    MODIFIER_PROPERTY_MODEL_SCALE,
         } end,
    CheckState      = function(self) return 
        {
--            [MODIFIER_STATE_UNSELECTABLE] = true,          
--            [MODIFIER_STATE_NO_HEALTH_BAR] = true,          
            [MODIFIER_STATE_INVULNERABLE] = true, 
            [MODIFIER_STATE_MAGIC_IMMUNE] = true, 
--            [MODIFIER_STATE_STUNNED] = true, 
--            [MODIFIER_STATE_ROOTED] = true, 
        } end,
})

function modifier_roshan_second_chance_effect:OnCreated(data)
	if IsServer() then
		local parent = self:GetParent()

		self.regen = data.total_regen/data.duration
		Sounds:CreateGlobalSound("roshan_second_chance")	
	end
end

function modifier_roshan_second_chance_effect:GetTexture()
    return "item_aegis"
end

function modifier_roshan_second_chance_effect:GetModifierModelScale()
    return 25--self:GetStackCount()
end

function modifier_roshan_second_chance_effect:GetModifierHealthRegenPercentage()
    return self.regen
end

function modifier_roshan_second_chance_effect:GetEffectName()
    return "particles/items_fx/aegis_respawn_timer.vpcf"
end
