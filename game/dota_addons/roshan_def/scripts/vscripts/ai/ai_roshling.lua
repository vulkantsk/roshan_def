function Spawn()
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end
    thisEntity:SetContextThink("SimpleRoshlingThink", SimpleRoshlingThink, 0)
end

function MegaModeRoshlingThink()
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
    if (not npc.megaModeInitialized) then
        npc.direPoint = Entities:FindByName(nil, "n_waypoint19")
        local roshanMegaModeAbilities = {
            "cleave",
            "respawn_strong",
            "roshdef_roshling_critical_strike",
            "roshdef_roshling_defense_aura"
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
        npc.abilitiesTable = {}
        for _, ability in pairs(roshanMegaModeAbilities) do
            local addedAbility = npc:AddAbility(ability)
            if (addedAbility) then
                addedAbility:SetLevel(1)
            end
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
        AttackMove(npc, enemies[1])
    else
        AttackMove(npc, npc.direPoint)
    end
    return 0.5
end

function SimpleRoshlingThink()
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
        local roshlingAbilities = {
            "cleave",
            "respawn_strong"
        }
        npc.abilitiesTable = {}
        for _, ability in pairs(roshlingAbilities) do
            local addedAbility = npc:AddAbility(ability)
            if (addedAbility) then
                addedAbility:SetLevel(1)
                table.insert(npc.abilitiesTable, addedAbility)
            end
        end
        npc.vInitialSpawnPos = npc:GetOrigin()        -- точка спавна юнита
        npc.fMaxDist = npc:GetAcquisitionRange()    -- радиус агра
        npc.bInitialized = true                        -- флаг инициализации
        npc.agro = false                            -- флаг агра
    end
    if GameRules.MegaMode == 1 then
        thisEntity:SetContextThink("MegaModeRoshlingThink", MegaModeRoshlingThink, 0)
        return -1
    end
    return 1
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
