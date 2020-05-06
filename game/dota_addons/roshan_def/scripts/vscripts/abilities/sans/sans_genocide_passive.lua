sans_genocide_passive = class({})
function sans_genocide_passive:GetIntrinsicModifierName() return 'sans_modifier_genocide_passive_particle' end 
LinkLuaModifier("sans_modifier_genocide_passive_particle", 'abilities/sans/sans_genocide_passive.lua', LUA_MODIFIER_MOTION_NONE)

sans_modifier_genocide_passive_particle = class({})
function sans_modifier_genocide_passive_particle:IsHidden() return true end
function sans_modifier_genocide_passive_particle:IsPermanent() return true end
function sans_modifier_genocide_passive_particle:OnCreated()
	if IsClient() then return end

	local particle = ParticleManager:CreateParticle('particles/sans/attach_eyes_c.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eye", self:GetCaster():GetAbsOrigin(), true)
end
