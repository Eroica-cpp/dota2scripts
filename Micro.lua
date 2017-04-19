local Micro = {}

Micro.optionEnabled = Menu.AddOption({"Utility","Micro"},"Auto Farm", "auto farm lane creep or neutral creep")
Micro.key = Menu.AddKeyOption({ "Utility", "Micro" }, "Turn On/Off Key", Enum.ButtonCode.KEY_T)
Micro.font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

local shouldGoFarm = false
local lasttime
local delay = 0.05

function Micro.OnUpdate()
    if not Menu.IsEnabled(Micro.optionEnabled) then return end
    if not shouldGoFarm then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    for i = 1, NPCs.Count() do
        local npc = NPCs.Get(i)
        -- Log.Write(tostring(NPC.GetUnitName(npc)) .. " " .. tostring(Entity.GetOwner(npc)) .. " " .. tostring(Entity.OwnedBy(npc, myHero)))
        if npc and npc ~= myHero and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
            Micro.Farm(npc)
        end
    end
end

function Micro.OnDraw()
    if not Menu.IsEnabled(Micro.optionEnabled) then return end

    if Menu.IsKeyDownOnce(Micro.key) then
        shouldGoFarm = not shouldGoFarm
    end

    if not shouldGoFarm then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    -- draw when farming key up
    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)
    Renderer.SetDrawColor(0, 255, 0, 255)
    Renderer.DrawTextCentered(Micro.font, x, y, "Micro", 1)
end

function Micro.Farm(npc)
    if not npc or not Entity.IsAlive(npc) then return end
    if lasttime and math.abs(GameRules.GetGameTime() - lasttime) <= delay then return end

    local myPlayer = Players.GetLocal()
    if not myPlayer then return end

    -- local attackRange = NPC.GetAttackRange(npc)

    -- attack enemy hero if possible
    local heroRadius = 500
    local enemyHeroesAround = NPC.GetHeroesInRadius(npc, heroRadius, Enum.TeamType.TEAM_ENEMY)
    for i, enemy in ipairs(enemyHeroesAround) do
        if enemy 
            and Entity.IsAlive(enemy) 
            and not Entity.IsDormant(enemy) 
            and NPC.IsKillable(enemy)
            then
            Player.AttackTarget(myPlayer, npc, enemy, true)
            lasttime = GameRules.GetGameTime()
            return
        end
    end    

    local creepRadius = 1200
    local unitsAround = NPC.GetUnitsInRadius(npc, creepRadius, Enum.TeamType.TEAM_BOTH)
    -- last hit
    for i, creep in ipairs(unitsAround) do
        local physicalDamage = NPC.GetTrueDamage(npc) * NPC.GetArmorDamageMultiplier(creep)
        if Entity.IsAlive(creep) 
            and not Entity.IsDormant(creep) 
            and not Entity.IsSameTeam(npc, creep) 
            and NPC.IsKillable(creep)
            and Entity.GetHealth(creep) <= physicalDamage
            then
            Player.AttackTarget(myPlayer, npc, creep, true)
            lasttime = GameRules.GetGameTime()
            return
        end
    end

    -- hit creeps (not last hit)
    for i, creep in ipairs(unitsAround) do
        local physicalDamage = NPC.GetTrueDamage(npc) * NPC.GetArmorDamageMultiplier(creep)
        if Entity.IsAlive(creep) 
            and not Entity.IsDormant(creep) 
            and not Entity.IsSameTeam(npc, creep) 
            and NPC.IsKillable(creep)
            and Entity.GetHealth(creep) > 2 * physicalDamage
            then
            Player.AttackTarget(myPlayer, npc, creep, true)
            lasttime = GameRules.GetGameTime()
            return
        end
    end

    -- auto follow friend hero or creep
    for i, creep in ipairs(unitsAround) do
        if Entity.IsSameTeam(npc, creep) 
            and Entity.IsAlive(creep) 
            and (NPC.IsCreep(creep) or NPC.IsHero(creep))
            and creep ~= Heroes.GetLocal() 
            then
            Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET, creep, Vector(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
            lasttime = GameRules.GetGameTime()
            return
        end
    end

end

return Micro