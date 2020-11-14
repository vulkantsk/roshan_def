function Spawn()
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end
    thisEntity:SetContextThink("SimpleRoshanThink", SimpleRoshanThink, 1)
end

function MegaModeRoshanThink()
    if (not thisEntity:IsAlive()) then
        --если юнит мертв
        return -1
    end

    if GameRules:IsGamePaused() == true then
        --если игра приостановлена
        return 1
    end

    if thisEntity:IsChanneling() then
        -- если юнит кастует скил
        return 0.5
    end
    if (thisEntity.lastUsedAbility and thisEntity.lastUsedAbility:IsInAbilityPhase()) then
        return 0.5
    end
    local npc = thisEntity
    if (not npc.megaModeInitialized) then
        npc.direPoint = Entities:FindByName(nil, "n_waypoint19")
        local roshanMegaModeAbilities = {
            "roshdef_roshan_slam",
            "roshdef_roshan_fire_breath",
            "roshdef_roshan_spell_block",
            "roshdef_roshan_protection_of_the_ancient",
            "roshdef_roshan_second_chance",
            "roshdef_roshan_rage",
            "roshdef_roshan_bash",
            "true_strike_datadriven",
            "cleave"
        }
        npc:AddNewModifier(
                npc,
                nil,
                "modifier_roshan_megamode_buff",
                {
                    duration = -1
                }
        )
        for _, ability in pairs(npc.abilitiesTable) do
            npc:RemoveAbilityByHandle(ability)
        end
        for _, ability in pairs(roshanMegaModeAbilities) do
            local addedAbility = npc:AddAbility(ability)
            if (addedAbility) then
                addedAbility:SetLevel(1)
            end
        end
        npc.abilitiesTable = {}
        for i = 0, npc:GetAbilityCount() - 1 do
            npc.abilitiesTable[i] = FindAbility(npc, i)
        end
        npc.megaModeInitialized = true
    end
    local searchRadius                            -- радиус поиска зависит от того, имеет ли юнит агр
    if npc.agro then
        searchRadius = npc.fMaxDist * 1.5
    else
        searchRadius = npc.fMaxDist
    end
    local enemies = FindUnitsInRadius(
            npc:GetTeamNumber(), --команда юнита
            npc:GetAbsOrigin(), --местоположение юнита
            nil, --айди юнита (необязательно)
            searchRadius + 50, --радиус поиска
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- юнитов чьей команды ищем вражеской/дружественной
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, --юнитов какого типа ищем
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, --поиск по флагам
            FIND_CLOSEST, --сортировка от ближнего к дальнему
            false)
    if (#enemies > 0) then
        local target = enemies[1]
        for _, ability in pairs(npc.abilitiesTable) do
            if (TryCastAbility(ability, npc, target) == true) then
                npc.lastUsedAbility = ability
                return 0.5
            end
        end
        AttackMove(npc, target)
        return 0.5
    else
        AttackMove(npc, npc.direPoint)
    end
    return 0.5
end

function SimpleRoshanThink()
    if (not thisEntity:IsAlive()) then
        --если юнит мертв
        return -1
    end

    if GameRules:IsGamePaused() == true then
        --если игра приостановлена
        return 1
    end

    if thisEntity:IsChanneling() then
        -- если юнит кастует скил
        return 1
    end
    local npc = thisEntity
    if not npc.bInitialized then
        local roshanAbilities = {
            "roshan_spell_block",
            "roshan_bash",
            "roshdef_roshan_second_chance",
            "true_strike_datadriven",
            "cleave"
        }
        for _, ability in pairs(roshanAbilities) do
            local addedAbility = npc:AddAbility(ability)
            if (addedAbility) then
                addedAbility:SetLevel(1)
            end
        end
        npc.abilitiesTable = {}
        for i = 0, npc:GetAbilityCount() - 1 do
            npc.abilitiesTable[i] = FindAbility(npc, i)
        end
        npc.vInitialSpawnPos = npc:GetOrigin()        -- точка спавна юнита
        npc.fMaxDist = npc:GetAcquisitionRange()    -- радиус агра
        npc.bInitialized = true                        -- флаг инициализации
        npc.agro = false                            -- флаг агра
    end
    if GameRules.MegaMode == 1 then
        thisEntity:SetContextThink("MegaModeRoshanThink", MegaModeRoshanThink, 0)
        return -1
    end
    local search_radius                            -- радиус поиска зависит от того, имеет ли юнит агр
    if npc.agro then
        search_radius = npc.fMaxDist * 1.5            -- расшираяется
    else
        search_radius = npc.fMaxDist                -- становится обычным
    end

    -- Как далеко юнит находится от своей точки спавна ?
    local fDist = (npc:GetOrigin() - npc.vInitialSpawnPos):Length2D()
    if fDist > search_radius then
        RetreatHome()            -- если юнит слишком далеко, то идет на точку спавна
        return 3
    end

    local enemies = FindUnitsInRadius(
            npc:GetTeamNumber(), --команда юнита
            npc:GetAbsOrigin(), --местоположение юнита
            nil, --айди юнита (необязательно)
            search_radius + 50, --радиус поиска
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- юнитов чьей команды ищем вражеской/дружественной
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, --юнитов какого типа ищем
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, --поиск по флагам
            FIND_CLOSEST, --сортировка от ближнего к дальнему
            false)

    if #enemies > 0 then
        -- если найденных юнитов нету
        local enemy = enemies[1]    -- врагом выбирается первый близжайший
        AttackMove(npc, enemy)
        return 0.5
    end

    if #enemies == 0 then
        -- если найденных юнитов нету
        if npc.agro then
            RetreatHome()    -- если юнит под действием агра
        end
        return 0.5
    end

    local enemy = enemies[1]    -- врагом выбирается первый близжайший
    if npc.agro then
        -- если юнит находится под действием агра

        AttackMove(npc, enemy)
    else
        local allies = FindUnitsInRadius(-- ищет всех союзных братков в радиусе
                npc:GetTeamNumber(),
                npc.vInitialSpawnPos,
                nil,
                npc.fMaxDist,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                FIND_CLOSEST,
                false)

        for i = 1, #allies do
            -- заставляет братков быть агрессивными и атаковать врага
            local ally = allies[i]
            ally.agro = true    -- накладывает действие агра
            AttackMove(ally, enemy)
        end
    end
    return 1

end

function FindAbility(unit, index)
    local ability = unit:GetAbilityByIndex(index)

    if ability then
        local ability_behavior = ability:GetBehaviorInt()

        if bit.band(ability_behavior, DOTA_ABILITY_BEHAVIOR_PASSIVE) == DOTA_ABILITY_BEHAVIOR_PASSIVE then
            ability.behavior = "passive"    -- способность пассивна
        elseif bit.band(ability_behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
            ability.behavior = "target"        -- способность направлена на юнита
        elseif bit.band(ability_behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
            ability.behavior = "no_target"    -- способность без цели
        elseif bit.band(ability_behavior, DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR_POINT then
            ability.behavior = "point"        -- способность направлена на точку
        end
        --		print("ability #"..index.." name = "..ability:GetAbilityName())
        --		print("ability behavior = "..ability.behavior)
        return ability
    else
        --   		print("ability #"..index.."not found !!!")
        return nil
    end

end

function TryCastAbility(ability, caster, enemy)

    if ability == nil -- способность существует ?
            or not ability:IsFullyCastable() -- способность можно использовать?
            or ability.behavior == "passive" -- способность пассивна ?
            or enemy:IsMagicImmune() then
        -- цель имеет уммунитет к магии ?
        return false
    end
    if (ability:GetAbilityName() == "roshdef_roshan_slam") then
        local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                300,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                FIND_ANY_ORDER,
                false)
        if (#enemies <= 2) then
            return false
        end
    end
    local order_type
    if ability.behavior == "target" then
        order_type = DOTA_UNIT_ORDER_CAST_TARGET    -- на цель
    elseif ability.behavior == "no_target" then
        order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET    -- без цели
    elseif ability.behavior == "point" then
        order_type = DOTA_UNIT_ORDER_CAST_POSITION    -- на точку
    elseif ability.behavior == "passive" then
        return false
    end

    ExecuteOrderFromTable({
        UnitIndex = caster:entindex(), -- индекс кастера
        OrderType = order_type, -- тип приказа
        AbilityIndex = ability:entindex(), -- индекс способности
        TargetIndex = enemy:entindex(), -- индекс врага
        Position = enemy:GetOrigin(), -- положение врага
        Queue = false, -- ждать очереди ?
    })
    return true
end

function AttackMove(unit, enemy)
    if enemy == nil then
        return
    end
    --	print("ATTACK MOVE")
    ExecuteOrderFromTable({
        UnitIndex = unit:entindex(), --индекс кастера
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, -- тип приказа атака
        Position = enemy:GetOrigin(), -- пощиция врага
        Queue = false,
    })

    return 1
end

function RetreatHome()
    thisEntity.agro = false    -- снимается действие агра

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = thisEntity.vInitialSpawnPos
    })
end

