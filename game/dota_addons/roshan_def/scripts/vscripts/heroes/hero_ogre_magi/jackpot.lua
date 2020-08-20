ogre_magi_jackpot = class({})

function Pracache(context)
	PrecacheResource("particle_folder", "particles/ogre_magi", context)
end

function ogre_magi_jackpot:OnSpellStart()
	local caster = self:GetCaster()

	local gold = RandomInt(self:GetSpecialValueFor("min_gold"), self:GetSpecialValueFor("max_gold"))
	gold = tostring(gold)

	local particle = "particles/ogre_magi/ogre_magi_jackpot.vpcf"
	local Is_x4 = 1 --* значит 4 цифры

	local numbers = {}
	local vectors = {
		[1] = {
			Vector(-10, 0, 320),
			Vector(30, 0, 320),
			Vector(65, 0, 320),
			Vector(105, 0, 320)
		},
		[2] = {
			Vector(10, 0, 320),
			Vector(45, 0, 320),
			Vector(80, 0, 320)
		}
	}

	for i = 1, #gold do
		local char = gold:sub(i, i)
		char = tonumber(char)
		numbers[i] = char + 10
	end

	if #gold < 4 then
		particle = "particles/econ/items/ogre_magi/ogre_magi_jackpot/ogre_magi_jackpot_spindle_rig.vpcf"
		Is_x4 = 2 --* значит 3 цифры
	end

	local jackpot_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl(jackpot_particle, 0, caster:GetAbsOrigin())

	for i = 1, #gold do
		local pfx = ParticleManager:CreateParticle("particles/ogre_magi/ogre_magi_jackpot_multicast_counter_b_glow.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin() + vectors[Is_x4][i])
		ParticleManager:SetParticleControl(pfx, 1, Vector(numbers[i], 0, 0))
	end

	gold = tonumber(gold)

	if gold > self:GetSpecialValueFor("max_gold") * 0.8 then
		EmitSoundOn("Hero_OgreMagi.Fireblast.x3", caster)
		for i = 1, 5 do
			local coins_particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(coins_particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(coins_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		end

	elseif gold < self:GetSpecialValueFor("max_gold") * 0.8 and self:GetSpecialValueFor("max_gold") * 0.6 then
		EmitSoundOn("Hero_OgreMagi.Fireblast.x2", caster)
		for i = 1, 3 do
			local coins_particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(coins_particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(coins_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		end

	else
		EmitSoundOn("Hero_OgreMagi.Fireblast.x1", caster)
		for i = 1, 1 do
			local coins_particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(coins_particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(coins_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		end
	end

	caster:ModifyGold(gold, false, 0)
end