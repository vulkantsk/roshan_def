LinkLuaModifier("modifier_ability_thief_1_passive", 'abilities/thief/ability_thief_1.lua', LUA_MODIFIER_MOTION_NONE)

ability_thief_1 = class({
})

function ability_thief_1:GetCastRAnge()
	return self:GetSpecialValueFor("radius")
end

function ability_thief_1:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius')
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetOrigin(), 
		caster, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_NONE, 
		FIND_ANY_ORDER, 
		false)
	local unit
	for _,cur_unit in pairs(units) do
		local items = {}
		for i= DOTA_ITEM_SLOT_1 ,DOTA_STASH_SLOT_3 do
			local item = cur_unit:GetItemInSlot(i)
			if item then 
				table.insert(items,i)
			end
		end
		if #items > 0 then 
			local itemSlot = items[RandomInt(1,#items)]
			self.items = self.items or {}
			local item = cur_unit:GetItemInSlot(itemSlot)
			local item_name = item:GetName()
			local item_charges = item:GetCurrentCharges()
			local entIndex = cur_unit:GetEntityIndex()
			self.items[entIndex] = self.items[entIndex] or {}
			table.insert(self.items[entIndex],{item_name = item_name, item_charges = item_charges})
			caster:AddNewModifier(caster,self, "modifier_ability_thief_1_passive", nil)
			item:RemoveSelf()

			local new_item = caster:AddItemByName(item_name)
			new_item:SetCurrentCharges(item_charges)
			unit = cur_unit
			break
		end
	end
	if unit then 
		ProjectileManager:CreateTrackingProjectile( {
			Target = caster,
			Source = unit,
			Ability = self,
			EffectName = 'particles/econ/items/rubick/rubick_arcana/rubick_arc_spell_steal_default.vpcf',
			bDodgeable = false,
			bProvidesVision = false,
			iMoveSpeed = 1100,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		})
	end
end

--function ability_thief_1:GetIntrinsicModifierName()
--	return 'modifier_ability_thief_1_passive'
--end

function ability_thief_1:OnProjectileHit(hTarget,vLocation)
	if hTarget == self:GetCaster() then 

	end
end

modifier_ability_thief_1_passive = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    IsPermanent 			= function(self) return false end,

})

function modifier_ability_thief_1_passive:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	local ability = parent:FindAbilityByName('ability_thief_1')
	if ability and ability.items then 
		for entIndex,data in pairs(ability.items) do
			local hero = EntIndexToHScript(entIndex) 
			if hero then 
				ProjectileManager:CreateTrackingProjectile( {
					Target = hero,
					Source = parent,
					Ability = ability,
					EffectName = 'particles/econ/items/rubick/rubick_arcana/rubick_arc_spell_steal_default.vpcf',
					bDodgeable = false,
					bProvidesVision = false,
					iMoveSpeed = 1100,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				})
				for __,item in pairs(data) do
					local new_item = hero:AddItemByName(item.item_name)
					new_item:SetCurrentCharges(item.item_charges)
					new_item:SetPurchaseTime(0)
				end
			end
		end
	end
end