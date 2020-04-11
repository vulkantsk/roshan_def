Sounds = Sounds or {
  	playerSounds = {},
  	playersStateMusic = {},
  	SoundDuration = {
  		["oingo_boingo_1"] = 90,
  		["oingo_boingo_2"] = 88,
  		["akvalazi"] = 85,
  		["boss_spawn"] = 10,
  		["krutoe_pike"] = 74,
  		["megalovania"] = 150,
  		["sandopolis"] = 146,
  		["satan_bal"] = 214,
  		["zoldik"] = 63,
  	},
}

function Sounds:Activate()
	CustomGameEventManager:RegisterListener( "set_sound_state", function( _, data )
		if data.state == 1 then
			self:ComebackClientSounds( data.PlayerID )
		else
			self:RemoveClientSounds( data.PlayerID )
		end
		self.playersStateMusic[data.PlayerID] = data.state == 1
	end )

	CustomGameEventManager:RegisterListener( "looping_sound_test", function( _, data )
		Sounds:CreateLoopingSoundOnClient( data.PlayerID, "Hero_Clinkz.Pick" )
	end )
	CustomGameEventManager:RegisterListener( "looping_sound_test_end", function( _, data )
		Sounds:RemoveLoopingSoundOnClient( data.PlayerID, "Hero_Clinkz.Pick" )
	end )
  	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
end

function Sounds:OnGameRulesStateChange()
  	local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
      	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 1 )
    end
end

function Sounds:OnThink()
	local now = GameRules:GetGameTime()
--	print("current time = "..now)

	for id, sounds in pairs( self.playerSounds ) do
		if self.playersStateMusic[id] then
			for sound, time in pairs( sounds ) do
				if now >= time then
					time = nil
					self:CreateLoopingSoundOnClient( id, sound )
				end
			end
		end
	end

	return 1
end

function Sounds:GetSoundDuration( sound )
	return GameRules:GetGameModeEntity():GetSoundDuration( sound, nil )
end

function Sounds:CreateGlobalLoopingSound( sound )
	if self.SoundDuration[sound] then
		print("sound duration = "..self.SoundDuration[sound])
	end

    for id = 0,9 do       
        Sounds:CreateLoopingSoundOnClient(id, sound)
    end
end

function Sounds:CreateGlobalSound( sound )
    for id = 0,9 do       
        Sounds:CreateSoundOnClient(id, sound)
    end
end

function Sounds:RemoveGlobalSound( sound )
    for id = 0,9 do       
        Sounds:RemoveSoundOnClient(id, sound)
    end
end

function Sounds:RemoveGlobalLoopingSound( sound )
    for id = 0,9 do       
        Sounds:RemoveSoundOnClient(id, sound)
        self.playerSounds[id][sound] = nil
    end
end

function Sounds:CreateLoopingSoundOnClient( id, sound )
	if self.playersStateMusic[id] == false then 
		print("player state - false")
		print(self.playersStateMusic[id])
		return 
	end
	self:Player( id )

	if self.playersStateMusic[id] then
		self:CreateSoundOnClient( id, sound )
	end

	if self.SoundDuration[sound] then
		self.playerSounds[id][sound] = GameRules:GetGameTime() + self.SoundDuration[sound]
	end
end

function Sounds:RemoveLoopingSoundOnClient( id, sound )
	self:Player( id )

	self:RemoveSoundOnClient( id, sound )
	self.playerSounds[id][sound] = nil
end

function Sounds:CreateSoundOnClient( id, sound )
	if self.playersStateMusic[id] == false then return end
	local player = PlayerResource:GetPlayer( id )
	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, "emit_sound", { sound = sound} )
	end
end

function Sounds:RemoveSoundOnClient( id, sound )
	local player = PlayerResource:GetPlayer( id )

	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, "stop_sound", { sound = sound} )
	end
end

function Sounds:ComebackClientSounds( id )
	self:Player( id )

	if not self.playersStateMusic[id] then
		self.playersStateMusic[id] = true

		for sound, time in pairs( self.playerSounds[id] ) do
			print(self.playersStateMusic[id])
			print(sound)
			self:CreateLoopingSoundOnClient( id, sound )
		end
	end
end

function Sounds:RemoveClientSounds( id )
	self:Player( id )

	if self.playersStateMusic[id] then
		self.playersStateMusic[id] = false

		for sound, _ in pairs( self.playerSounds[id] ) do
			self:RemoveSoundOnClient( id, sound )
		end
	end
end

function Sounds:Player( id )
	if not self.playerSounds[id] then
		self.playerSounds[id] = {}
		self.playersStateMusic[id] = true
	end
end

Sounds:Activate()