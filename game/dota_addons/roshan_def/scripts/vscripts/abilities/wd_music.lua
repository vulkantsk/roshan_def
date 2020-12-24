LinkLuaModifier( "modifier_witch_doctor_music", "abilities/wd_music.lua", LUA_MODIFIER_MOTION_NONE )			-- Owner's bonus attributes, stackable
current_music_number = 1
music_list1 = {
}
music_list = {
--	{ name = "wrath_music", duration = 27},
	{ name = "auf_1", duration = 28},
	{ name = "auf_2", duration = 28},
	{ name = "durak_molnia_1", duration = 48},
	{ name = "durak_molnia_2", duration = 36},
	{ name = "enjoykin_gagarin_1", duration = 45},
	{ name = "enjoykin_gagarin_2", duration = 55},
	{ name = "enjoykin_idushiy_1", duration = 45},
	{ name = "enjoykin_idushiy_2", duration = 69},
	{ name = "enjoykin_jitie_1", duration = 54},
	{ name = "enjoykin_jitie_2", duration = 58},
	{ name = "enjoykin_kosmos_1", duration = 49},	
	{ name = "enjoykin_kosmos_2", duration = 32},	
	{ name = "enjoykin_kosmos_3", duration = 33},	
	{ name = "enjoykin_obrashenie_1", duration = 60},	
	{ name = "enjoykin_obrashenie_2", duration = 69},	
	{ name = "enjoykin_pacan_1", duration = 39},	
	{ name = "enjoykin_pacan_2", duration = 47},	
	{ name = "enjoykin_pacan_3", duration = 57},	
	{ name = "enjoykin_pisun_1", duration = 45},	
	{ name = "enjoykin_pisun_2", duration = 75},	
	{ name = "enjoykin_pureshka_1", duration = 49},	
	{ name = "enjoykin_pureshka_2", duration = 48},	
	{ name = "enjoykin_russkie_idut_1", duration = 45},	
	{ name = "enjoykin_russkie_idut_2", duration = 44},	
	{ name = "enjoykin_russkie_idut_3", duration = 43},	
	{ name = "enjoykin_semechki_1", duration = 33},	
	{ name = "enjoykin_semechki_2", duration = 49},	
	{ name = "enjoykin_semechki_3", duration = 36},	
	{ name = "enjoykin_spas_kota_1", duration = 48},	
	{ name = "enjoykin_spas_kota_2", duration = 50},	
	{ name = "enjoykin_startuem_1", duration = 32},	
	{ name = "enjoykin_startuem_2", duration = 35},	
	{ name = "kaskaderi_1", duration = 50},	
	{ name = "kaskaderi_2", duration = 51},	
	{ name = "malikov_mama", duration = 33},	
	{ name = "meladze_sahara_1", duration = 76},	
	{ name = "meladze_sahara_2", duration = 61},	
	{ name = "na_zare_1", duration = 36},	
	{ name = "na_zare_2", duration = 39},	
	{ name = "najmi_knopku_1", duration = 68},	
	{ name = "najmi_knopku_2", duration = 50},	
	{ name = "pozvoni_mne_1", duration = 49},	
	{ name = "pozvoni_mne_2", duration = 48},	
	{ name = "pozvoni_mne_3", duration = 47},	
	{ name = "pozvoni_mne_4", duration = 50},	
	{ name = "qontrast_dim_1", duration = 37},	
	{ name = "qontrast_dim_2", duration = 50},	
	{ name = "shantel_disco_boy_1", duration = 28},	
	{ name = "shantel_disco_boy_2", duration = 52},	
	{ name = "shantel_disco_boy_3", duration = 34},	
	{ name = "shantel_disco_boy_4", duration = 72},	
	{ name = "splinter_1", duration = 62},	
	{ name = "splinter_2", duration = 58},	
	{ name = "splinter_3", duration = 52},	
	{ name = "taet_led", duration = 48},	
	{ name = "town_road_1", duration = 43},	
	{ name = "town_road_2", duration = 44},	
	{ name = "trava", duration = 66},	
	{ name = "valim_1", duration = 27},	
	{ name = "valim_2", duration = 27},	
	{ name = "alchemist_1", duration = 42},
	{ name = "alchemist_2", duration = 48},
	{ name = "death_note_op_1", duration = 34},
	{ name = "death_note_op_2", duration = 51},
	{ name = "death_note_op_3", duration = 56},
	{ name = "loli_mou_1", duration = 32},
	{ name = "loli_mou_2", duration = 32},
	{ name = "naruto_op_1", duration = 38},
	{ name = "naruto_op_2", duration = 42},
	{ name = "niletto_lubimka", duration = 32},
	{ name = "parasyte_speak_1", duration = 40},
	{ name = "parasyte_speak_2", duration = 42},
	{ name = "parasyte_theme_1", duration = 41},
	{ name = "parasyte_theme_2", duration = 43},
	{ name = "fly_mach", duration = 41},
	{ name = "jojo_op_1", duration = 58},
	{ name = "jojo_op_2", duration = 54},
	{ name = "igor_doroga1", duration = 26},
	{ name = "igor_doroga2", duration = 25},
	{ name = "igor_doroga3", duration = 30},
	{ name = "igor_doroga4", duration = 26},	
	{ name = "gluttony_music", duration = 32},
	{ name = "envy_music", duration = 25},
	{ name = "pride_music", duration = 43},
	{ name = "greed_music", duration = 32},
	{ name = "lust_music", duration = 25},
	{ name = "sloth_music", duration = 41},
	{ name = "Roshan_def.wd_dance", duration = 8},
	{ name = "dyadya_vova1", duration = 51},
	{ name = "dyadya_vova2", duration = 38},
	{ name = "dyadya_vova3", duration = 43},
	{ name = "stalker_bandit", duration = 43},
	{ name = "spulae_mulae", duration = 36},
	{ name = "glad_valakas", duration = 28},
	{ name = "undertale", duration = 19},
	{ name = "pivko", duration = 24},
	{ name = "totoro_theme", duration = 31},
}

function WDMusicStart1(keys)
	local caster = keys.caster
	caster.sound = true
	caster.sound_num = 0
	caster.sound_on = true
	
	Timers:CreateTimer(0.1,function()
		if caster.sound == false then
			return
		elseif caster.sound_on == false then
			return 1
		end
--		caster.sound_num = caster.sound_num + 1
--		caster.music = caster.sound_num%3+1
		caster.music = RandomInt(1,#music_list)
		print(caster.music)
		print("music_name = "..music_list[caster.music].name.." music_duraton = "..music_list[caster.music].duration)
		EmitSoundOn(music_list[caster.music].name,caster)
		
		 
		return music_list[caster.music].duration

	end)
	caster.timer = timer
end

function WDMusicStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.sound = true
	caster.sound_on = true
	
	local music_number = RandomInt(1,#music_list)
	local music_duration = music_list[music_number].duration
	local music_name = music_list[music_number].name
	caster:AddNewModifier(caster, ability, "modifier_witch_doctor_music", {duration = music_duration, music_name = music_name})
	print("music name = "..music_name)
end
function WDMusicStop(keys)
	local caster = keys.caster
	caster.sound = false
	StopSoundOn(music_list[caster.music].name, caster)
	for i=1,#music_list do
		StopSoundOn(music_list[i].name, caster)
	end	
end


function WDSoundOn(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if caster.sound_on == true then
		caster.sound_on = false
		caster:RemoveModifierByName("modifier_witch_doctor_music")
		caster:RemoveModifierByName("modifier_wd_music")
	else
		caster.sound_on = true
		local music_number = RandomInt(1,#music_list)
--		local music_number = current_music_number
		if current_music_number == #music_list then
			current_music_number = 1
		else
			current_music_number = current_music_number + 1
		end
		local music_duration = music_list[music_number].duration
		local music_name = music_list[music_number].name
		caster:AddNewModifier(caster, ability, "modifier_witch_doctor_music", {duration = music_duration, music_name = music_name})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_wd_music", nil)
 	end
end

modifier_witch_doctor_music = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
})
function modifier_witch_doctor_music:OnCreated(keys)
	local caster = self:GetCaster()
	self.music_name = keys.music_name

	EmitSoundOn(self.music_name, caster)
--	print("music = "..self.music_name)

	self:StartIntervalThink(2)
end

function modifier_witch_doctor_music:OnDestroy()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local music_name = self.music_name
	StopSoundOn(music_name, caster)
	
	if caster.sound_on == true then		
		local music_number = RandomInt(1,#music_list)
		local music_duration = music_list[music_number].duration
		local music_name = music_list[music_number].name
		caster:AddNewModifier(caster, ability, "modifier_witch_doctor_music", {duration = music_duration, music_name = music_name})
	end
end

function modifier_witch_doctor_music:OnIntervalThink()
	local parent = self:GetParent()
	
	local effect = "particles/econ/events/ti9/ti9_drums_musicnotes.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_POINT_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)	
end
