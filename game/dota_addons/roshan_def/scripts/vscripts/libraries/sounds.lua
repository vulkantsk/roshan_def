Sounds = Sounds or {
  	playerSounds = {},
  	globalLoopingSounds = {},
  	playerStates = {}
}

function Sounds:Activate()
	CustomGameEventManager:RegisterListener( "set_sound_state", function( _, data )
		if data.state == 1 then
			self:ComebackClientSounds( data.PlayerID )
		else
			self:RemoveClientSounds( data.PlayerID )
		end
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

	for sound, time in pairs( self.globalLoopingSounds ) do
		print(now)
    print(time)
    if now >= time then
			self:CreateGlobalLoopingSound( sound )
		end
	end

	for id, sounds in pairs( self.playerSounds ) do
		if self.playerStates[id] then
			for sound, time in pairs( sounds ) do
				if now >= time then
					self:CreateSoundOnClient( id, sound )
				end
			end
		end
	end
end

function Sounds:GetSoundDuration( sound )
	return GameRules:GetGameModeEntity():GetSoundDuration( sound, nil )
end

function Sounds:CreateGlobalLoopingSound( sound )
	Sounds:CreateGlobalSound( sound )
	self.globalLoopingSounds[sound] = GameRules:GetGameTime() + self:GetSoundDuration( sound )
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
	Sounds:RemoveGlobalSound( sound )
	self.globalLoopingSounds[sound] = nil
end

function Sounds:CreateLoopingSoundOnClient( id, sound )
	self:Player( id )

	if self.playerStates[id] then
		self:CreateSoundOnClient( id, sound )
	end

	self.playerSounds[id][sound] = GameRules:GetGameTime() + self:GetSoundDuration( sound )
end

function Sounds:RemoveLoopingSoundOnClient( id, sound )
	self:Player( id )

	self:RemoveSoundOnClient( id, sound )
	self.playerSounds[id][sound] = nil
end

function Sounds:CreateSoundOnClient( id, sound )
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

	if not self.playerStates[id] then
		self.playerStates[id] = true

		for sound, time in pairs( self.playerSounds[id] ) do
			self:CreateLoopingSoundOnClient( id, sound )
		end
	end
end

function Sounds:RemoveClientSounds( id )
	self:Player( id )

	if self.playerStates[id] then
		self.playerStates[id] = false

		for sound, _ in pairs( self.playerSounds[id] ) do
			self:RemoveSoundOnClient( id, sound )
		end
	end
end

function Sounds:Player( id )
	if not self.playerSounds[id] then
		self.playerSounds[id] = {}
		self.playerStates[id] = true
	end
end
Sounds:Activate()