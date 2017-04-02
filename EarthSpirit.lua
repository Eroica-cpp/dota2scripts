local EarthSpirit = {}

EarthSpirit.optionKick = Menu.AddOption({"Hero Specific", "Earth Spirit"}, "Kick Helper", "auto place stone before kick if needed")
EarthSpirit.optionRoll = Menu.AddOption({"Hero Specific", "Earth Spirit"}, "Roll Helper", "auto place stone before roll if needed")
EarthSpirit.optionPull = Menu.AddOption({"Hero Specific", "Earth Spirit"}, "Pull Helper", "auto place stone before pull to silence enemy")


function EarthSpirit.OnPrepareUnitOrders(orders)
    if not orders or not orders.ability then return true end
    if not Entity.IsAbility(orders.ability) then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) then return true end

    if Menu.IsEnabled(EarthSpirit.optionKick) and Ability.GetName(orders.ability) == "earth_spirit_boulder_smash" then
        EarthSpirit.KickHelper(myHero, orders.position, orders.target)
        return true
        -- return false
    end

    if Menu.IsEnabled(EarthSpirit.optionRoll) and Ability.GetName(orders.ability) == "earth_spirit_rolling_boulder" then
        EarthSpirit.RollHelper(myHero, orders.position)
        return true
    end

    if Menu.IsEnabled(EarthSpirit.optionPull) and Ability.GetName(orders.ability) == "earth_spirit_geomagnetic_grip" then
        EarthSpirit.PullHelper(myHero, orders.position)
        return true
    end

    return true
end

function EarthSpirit.KickHelper(myHero, pos, target)
    Log.Write("yoyoyo!!!")
    -- if not myHero then return end

    -- local kick = NPC.GetAbility(myHero, "earth_spirit_boulder_smash")
    -- if not kick or not Ability.IsCastable(kick, NPC.GetMana(myHero)) then return end

    -- if target then
    --     Ability.CastTarget(kick, target)
    --     return
    -- end

    -- local stone = NPC.GetAbility(myHero, "earth_spirit_stone_caller")
    -- if not stone or not Ability.IsCastable(stone, 0) then return end

    -- if not pos then return end

    -- local origin = NPC.GetAbsOrigin(myHero)
    -- local place_pos = origin + (pos - origin):Normalized():Scaled(100)
    
    -- Ability.CastPosition(stone, place_pos)
    -- Ability.CastPosition(kick, place_pos)
end

function EarthSpirit.RollHelper(myHero, pos)
    if not myHero or not pos then return end

    local stone = NPC.GetAbility(myHero, "earth_spirit_stone_caller")
    if not stone or not Ability.IsCastable(stone, 0) then return end

    -- local mod = NPC.GetModifier(myHero, "modifier_earth_spirit_stone_caller_charge_counter")
    -- if not mod or Modifier.GetStackCount(mod) <= 0 then return end

    local origin = NPC.GetAbsOrigin(myHero)
    local dis = (origin - pos):Length()

    local default_distance = 600
    if dis <= default_distance then return end

    local place_pos = origin + (pos - origin):Normalized():Scaled(100)
    Ability.CastPosition(stone, place_pos)
end

function EarthSpirit.PullHelper(myHero, pos)
    if not myHero or not pos then return end

    local radius = 180
    if EarthSpirit.HasStoneInRadius(myHero, pos, radius) then return end
    
    local stone = NPC.GetAbility(myHero, "earth_spirit_stone_caller")
    if not stone or not Ability.IsCastable(stone, 0) then return end

    local range = 1100
    local dis = (NPC.GetAbsOrigin(myHero) - pos):Length()
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

return EarthSpirit