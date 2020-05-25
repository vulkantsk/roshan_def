LinkLuaModifier("modifier_damage_test", "abilities/dummy_test_damage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_test_filter", "abilities/dummy_test_damage", LUA_MODIFIER_MOTION_NONE)

damage_test = class({})

function damage_test:GetIntrinsicModifierName()
	return "modifier_damage_test"
end

modifier_damage_test = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}end,
})

function modifier_damage_test:CanParentBeAutoAttacked()
	return false
end

function modifier_damage_test:GetMinHealth()
	return 1
end


function modifier_damage_test:OnTakeDamage( data )
	-- Variables
	local damage = data.damage
	local attacker = data.attacker
	local unit = data.unit
	local caster = self:GetCaster()

	if unit == caster and caster:IsAlive() then
		caster:SetBaseMaxHealth(caster:GetMaxHealth() + damage)
		caster:SetHealth(caster:GetMaxHealth())
		if caster:GetMaxHealth() > 100000000   then
			if caster:GetMaxHealth() < 101000000 then 
				local point = caster:GetAbsOrigin()
				local newItem = CreateItem( "item_imba_spell_fencer", nil, nil )
				local drop = CreateItemOnPositionSync( point, newItem )
			end
			caster:RemoveSelf()	
		end
		local ability = self:GetAbility()
		local duration = self:GetSpecialValueFor("duration")
		caster:AddNewModifier(caster, ability, "modifier_damage_test_filter", {duration = duration})
	end

end

modifier_damage_test_filter = class({
	IsHidden = function(self) return false end,
})
function modifier_damage_test_filter:OnDestroy()
	local caster = self:GetCaster()

	caster:SetMaxHealth(1)
	caster:SetBaseMaxHealth(1)
	caster:SetHealth(1)
end
