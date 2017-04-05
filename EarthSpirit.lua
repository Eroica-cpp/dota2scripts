-- ==================================
-- File Name : EarthSpirit.lua
-- Author    : Eroica
-- Version   : 1.2
-- Date      : 2017.4.5
-- ==================================

local EarthSpirit = {}

EarthSpirit.optionKick = Menu.AddOption({"Hero Specific", "Earth Spirit"}, "Kick Helper", "auto place stone before kick if needed")
EarthSpirit.optionRoll = Menu.AddOption({"Hero Specific", "Earth Spirit"}, "Roll Helper", "auto place stone before roll if needed")
EarthSpirit.optionPull = Menu.AddOption({"Hero Specific", "Earth Spirit"}, "Pull Helper", "auto place stone before pull to silence enemy")

function EarthSpirit.OnPrepareUnitOrders(orders)
    if not orders or not orders.ability then return true end
    if not Entity.IsAbility(orders.ability) then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return true end

    if Menu.IsEnabled(EarthSpirit.optionKick) and Ability.GetName(orders.ability) == "earth_spirit_boulder_smash" then
        EarthSpirit.KickHelper(myHero, orders.target)
        return false
    end

    if Menu.IsEnabled(EarthSpirit.optionRoll) and Ability.GetName(orders.ability) == "earth_spirit_rolling_boulder" then
        EarthSpirit.RollHelper(myHero)
        return true
    end

    if Menu.IsEnabled(EarthSpirit.optionPull) and Ability.GetName(orders.ability) == "earth_spirit_geomagnetic_grip" then
        EarthSpirit.PullHelper(myHero, orders.target)
        return true
    end

    return true
end

function EarthSpirit.KickHelper(myHero, target)
    if not myHero then return end

    local kick = NPC.GetAbility(myHero, "earth_spirit_boulder_smash")
    if not kick or not Ability.IsCastable(kick, NPC.GetMana(myHero)) then return end

    if target and (NPC.IsCreep(target) or NPC.IsHero(target)) then
        local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(target)):Length()
        local range = 150
        if dis <= range then
            Ability.CastTarget(kick, target)
            return
        end
    end

    local pos = Input.GetWorldCursorPos()
    local origin = Entity.GetAbsOrigin(myHero)
    local kick_pos = origin + (pos - origin):Normalized():Scaled(100)

    if not EarthSpirit.HasStoneInRadius(myHero, kick_pos, 160) and not EarthSpirit.HasStoneInRadius(myHero, origin, 200) then
        local stone = NPC.GetAbility(myHero, "earth_spirit_stone_caller")
        if stone and Ability.IsCastable(stone, 0) then
            Ability.CastPosition(stone, kick_pos)
        end
    end
    
    Ability.CastPosition(kick, kick_pos)
end

function EarthSpirit.RollHelper(myHero)
    if not myHero then return end

    local stone = NPC.GetAbility(myHero, "earth_spirit_stone_caller")
    if not stone or not Ability.IsCastable(stone, 0) then return end

    -- local mod = NPC.GetModifier(myHero, "modifier_earth_spirit_stone_caller_charge_counter")
    -- if not mod or Modifier.GetStackCount(mod) <= 0 then return end

    local pos = Input.GetWorldCursorPos()
    local origin = Entity.GetAbsOrigin(myHero)
    local dis = (origin - pos):Length()

    local default_distance = 600
    if dis <= default_distance then return end

    if EarthSpirit.HasStoneBetween(myHero, origin, pos) then return end

    local place_pos = origin + (pos - origin):Normalized():Scaled(100)
    Ability.CastPosition(stone, place_pos)
end

function EarthSpirit.PullHelper(myHero, target)
    if not myHero or not target then return end

    -- earth spirit can pull ally if has aghs scepter
    if NPC.HasItem(myHero, "item_ultimate_scepter", true) and Entity.IsSameTeam(myHero, target) then return end

    local pos = Input.GetWorldCursorPos()

    local radius = 180
    if EarthSpirit.HasStoneInRadius(myHero, pos, radius) then return end

    local stone = NPC.GetAbility(myHero, "earth_spirit_stone_caller")
    if not stone or not Ability.IsCastable(stone, 0) then return end

    local range = 1100
    local dis = (Entity.GetAbsOrigin(myHero) - pos):Length()
    if dis > range then return end

    Ability.CastPosition(stone, pos)
end

function EarthSpirit.HasStoneInRadius(myHero, pos, radius)
    if not pos or not radius then return false end

    local unitsAround = NPCs.InRadius(pos, radius, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
    for i, npc in ipairs(unitsAround) do
        if npc and NPC.GetUnitName(npc) == "npc_dota_earth_spirit_stone" then
            return true
        end
    end

    return false
end

function EarthSpirit.HasStoneBetween(myHero, pos1, pos2)
    if not myHero or not pos1 or not pos2 then return false end

    local radius = 150
    local dir = (pos2 - pos1):Normalized():Scaled(radius)
    local dis = (pos2 - pos1):Length()
    local num = math.floor(dis/radius)

    for i = 1, num do
        local mid = pos1 + dir:Scaled(i)
        if EarthSpirit.HasStoneInRadius(myHero, mid, radius) then
            return true
        end
    end

    return false
end

return EarthSpirit