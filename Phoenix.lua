-- ==================================
-- File Name : Phoenix.lua
-- Author    : Eroica
-- Version   : 3.1
-- Date      : 2017.5.16
-- ==================================
local Utility = require("Utility")

local Phoenix = {}

Phoenix.optionFireSpirit = Menu.AddOption({"Hero Specific","Phoenix"},"Auto Fire Spirit", "auto cast fire spirit")
Phoenix.optionSunRay = Menu.AddOption({"Hero Specific","Phoenix"},"Sun Ray Helper", "sun ray sticks to nearest hero to cursor (ally or enemy)")
Phoenix.castedEnemyList = {}

-- auto case fire spirit and use heavens right before supernova
function Phoenix.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(Phoenix.optionFireSpirit) then return true end
    if not orders or not orders.ability then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    if not Entity.IsAbility(orders.ability) then return true end
    if Ability.GetName(orders.ability) ~= "phoenix_supernova" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return true end

    local fire_spirit        = NPC.GetAbility(myHero, "phoenix_fire_spirits")
    local launch_fire_spirit = NPC.GetAbility(myHero, "phoenix_launch_fire_spirit")
    local heavens            = NPC.GetItem(myHero, "item_heavens_halberd", true)
    local supernova          = NPC.GetAbility(myHero, "phoenix_supernova")

    local myMana             = NPC.GetMana(myHero)
    local manaCost_supernova = Ability.GetManaCost(supernova)

    if heavens then
        local manaCost_heavens = Ability.GetManaCost(heavens)
        local range = Ability.GetCastRange(heavens) -- 600
        local enemyHeroes = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
        for i, enemy in ipairs(enemyHeroes) do
            if heavens and Ability.IsCastable(heavens, myMana - manaCost_supernova)
                and not NPC.IsIllusion(enemy) and not Utility.IsDisabled(enemy)
                and Utility.CanCastSpellOn(enemy) then
                Ability.CastTarget(heavens, enemy)
                myMana = myMana - manaCost_heavens
                break
            end
        end
    end

    if Ability.IsCastable(fire_spirit, myMana - manaCost_supernova) then
        Ability.CastNoTarget(fire_spirit)
    end

    if not Ability.IsCastable(launch_fire_spirit, 0) then return true end
    if not Ability.IsCastable(supernova, myMana) then return true end

    local range = Ability.GetCastRange(launch_fire_spirit) -- 1400
    local enemyHeroes = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    for i, enemy in ipairs(enemyHeroes) do
        if Ability.IsCastable(launch_fire_spirit, myMana) then
            Ability.CastPosition(launch_fire_spirit, Entity.GetAbsOrigin(enemy))
        end
    end

    return true
end

function Phoenix.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_phoenix" then return end

    if Menu.IsEnabled(Phoenix.optionFireSpirit) then
        Phoenix.FireSpirit(myHero)
    end

    if Menu.IsEnabled(Phoenix.optionSunRay) then
        Phoenix.SunRay(myHero)
    end
end

function Phoenix.SunRay(myHero)
    if not NPC.HasModifier(myHero, "modifier_phoenix_sun_ray") then return end

    local npc = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_BOTH)
    if not npc or not Utility.CanCastSpellOn(npc) then return end
    if not NPC.IsPositionInRange(npc, Input.GetWorldCursorPos(), 500, 0) then return end

    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, npc, Entity.GetAbsOrigin(npc), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

function Phoenix.FireSpirit(myHero)
    -- only auto cast fire spirit when diving or using sun ray
    if not NPC.HasModifier(myHero, "modifier_phoenix_icarus_dive") and not NPC.HasModifier(myHero, "modifier_phoenix_sun_ray") then return end

    local fireSpirit = NPC.GetAbility(myHero, "phoenix_launch_fire_spirit")
    if not fireSpirit or not Ability.IsCastable(fireSpirit, NPC.GetMana(myHero)) then return end

    local enemies = NPC.GetHeroesInRadius(myHero, Ability.GetCastRange(fireSpirit), Enum.TeamType.TEAM_ENEMY)
    if not enemies or #enemies <= 0 then return end

    for i, npc in ipairs(enemies) do
        if not Ability.IsCastable(fireSpirit, NPC.GetMana(myHero)) then break end

        if npc and Phoenix.ShouldCastFireSpiritOn(npc) then
            local speed = 900
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(npc)):Length()
            local delay = dis / speed
            local pos = Utility.GetPredictedPosition(npc, delay)

            Ability.CastPosition(fireSpirit, pos)
            Phoenix.castedEnemyList[NPC.GetUnitName(npc)] = GameRules.GetGameTime()
        end
    end
end

function Phoenix.ShouldCastFireSpiritOn(enemy)
    if NPC.HasModifier(enemy, "modifier_phoenix_fire_spirit_burn") then return false end
    if NPC.IsIllusion(enemy) then return false end
    if not Utility.CanCastSpellOn(enemy) then return false end

    if not Phoenix.castedEnemyList[NPC.GetUnitName(enemy)] then return true end

    local delay = 1400 / 900 + 1
    if GameRules.GetGameTime() - Phoenix.castedEnemyList[NPC.GetUnitName(enemy)] > delay then return true end

    return false
end

return Phoenix
