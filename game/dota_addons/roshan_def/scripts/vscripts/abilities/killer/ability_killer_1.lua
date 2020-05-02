ability_killer_1 = class({})
function ability_killer_1:GetIntrinsicModifierName() return 'modifier_ability_killer_1_passive' end
function ability_killer_1:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius')
	local unit = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetOrigin(), 
		caster, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_NONE, 
		FIND_ANY_ORDER, 
		false)[1]
	if unit then 
		self.targetUnit = unit
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
function ability_killer_1:OnProjectileHit(hTarget,vLocation)
	if hTarget == self:GetCaster() and self.targetUnit then 
		local data = {}
		for i= DOTA_ITEM_SLOT_1 ,DOTA_STASH_SLOT_3 do
			local item = self.targetUnit:GetItemInSlot(i)
			if item then 
				table.insert(data,i)
			end
		end
		if #data < 1 then return end
		local itemSlot = data[RandomInt(1,#data)]
		self.items = self.items or {}
		local item = self.targetUnit:GetItemInSlot(itemSlot)
		local entIndex = self.targetUnit:GetEntityIndex()
		self.items[entIndex] = self.items[entIndex] or {}
		table.insert(self.items[entIndex],item:GetAbilityName())
		item:RemoveSelf()
	end
end
LinkLuaModifier("modifier_ability_killer_1_passive", 'abilities/killer/ability_killer_1.lua', LUA_MODIFIER_MOTION_NONE)
modifier_ability_killer_1_passive = class({})
function modifier_ability_killer_1_passive:IsHidden() return true end 
function modifier_ability_killer_1_passive:IsPurgable() return false end 
function modifier_ability_killer_1_passive:IsDebuff() return false end 
function modifier_ability_killer_1_passive:IsBuff() return true end 
function modifier_ability_killer_1_passive:RemoveOnDeath() return true end 
function modifier_ability_killer_1_passive:IsPermanent() return false end 
function modifier_ability_killer_1_passive:OnDestroy()
	if IsClient() then return end
	local parent = self:GetParent()
	local ability = self:GetParent():FindAbilityByName('ability_killer_1')
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
				for __,itemName in pairs(data) do
					hero:AddItemByName(itemName)
				end
			end
		end
	end
end
