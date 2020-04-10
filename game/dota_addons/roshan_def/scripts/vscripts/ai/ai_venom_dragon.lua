
function Spawn( entityKeyValues )	-- вызывается когда юнит появляется
	if not IsServer() then		-- если сервер не отвечает
		return
	end

	if thisEntity == nil then	-- если данного юнита не существует
		return
	end

	NoTargetAbility1 = thisEntity:FindAbilityByName( "venom_dragon_poison_attack" ):ToggleAutoCast()

end


