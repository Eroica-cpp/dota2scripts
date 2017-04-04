local Utility = require("Utility")

local Magnus = {}

Magnus.optionEmpower = Menu.AddOption({"Hero Specific", "Magnus"}, "Auto Empower", "auto cast empower on allies or magnus himself")
Magnus.optionRPHelper = Menu.AddOption({"Hero Specific", "Magnus"}, "RP Helper", "Auto blink to best position for RP, auto turn around before RP")

local RP_timer
local ERROR = 0.05

-- blink to best position and turn around before RP
function Magnus.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(Magnus.optionRPHelper) then return true end
    if not orders or not orders.ability then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    if not Entity.IsAbility(orders.ability) then return true end
    if Ability.GetName(orders.ability) ~= "magnataur_reverse_polarity" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if (not Entity.IsAlive(myHero)) or NPC.IsStunned(myHero) then return true end

    if not Ability.IsCastable(orders.ability, NPC.GetMana(myHero)) then return true end

    local dir = Input.GetWorldCursorPos()

    local blink = NPC.GetItem(myHero, "item_blink", true)
    if blink and Ability.IsCastable(blink, 0) then
        local RP_radius = 410
        local blink_radius = 1200
        local enemyHeroes = NPC.GetHeroesInRadius(myHero, blink_radius, Enum.TeamType.TEAM_ENEMY)
        local pos = Utility.BestPosition(enemyHeroes, RP_radius)
        if pos then 
            Ability.CastPosition(blink, pos) 
        end
    end

    -- turn around
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, nil, dir, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY , myHero)
    RP_timer = GameRules.GetGameTime()
    return false
end

function Magnus.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_magnataur" then return end
    
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
    if NPC.IsChannellingAbility(myHero) then return end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return end
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

    if Menu.IsEnabled(Magnus.optionEmpower) then
        Magnus.AutoEmpower(myHero)
    end

    if Menu.IsEnabled(Magnus.optionRPHelper) then
        Magnus.RPHelper(myHero)
    end
end

-- auto cast empower on himself or needed ally heroes
-- priority: magnus -> melee ally hero -> ranged ally hero
function Magnus.AutoEmpower(myHero)
    local empower = NPC.GetAbilityByIndex(myHero, 1)
    if not empower or not Ability.IsCastable(empower, NPC.GetMana(myHero)) then return end

    -- avoid casting empower right before ultimate
    local enemiesAround = NPC.GetHeroesInRadius(myHero, 450, Enum.TeamType.TEAM_ENEMY)
    if enemiesAround and #enemiesAround > 0 then return end

    if not NPC.HasModifier(myHero, "modifier_magnataur_empower") then
        Ability.CastTarget(empower, myHero)
        return
    end

    local range = 800
    local alliesAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    if not alliesAround or #alliesAround <= 0 then return end

    -- for melee ally hero
    for i, ally in ipairs(alliesAround) do
        if not NPC.HasModifier(ally, "modifier_magnataur_empower") 
            and not NPC.IsIllusion(ally) and not NPC.IsRanged(ally) then
            Ability.CastTarget(empower, ally)
            return
        end
    end

    -- for range ally hero
    for i, ally in ipairs(alliesAround) do
        if not NPC.HasModifier(ally, "modifier_magnataur_empower") and not NPC.IsIllusion(ally) then
            Ability.CastTarget(empower, ally)
            return
        end
    end
end

function Magnus.RPHelper(myHero)
    local RP = NPC.GetAbilityByIndex(myHero, 3)
    if not RP or not Ability.IsCastable(RP, NPC.GetMana(myHero)) then return end

    if not RP_timer then return end

    -- magnus's turn rate is 0.8, 0.2s delay works well in practice.
    local delay = 0.2
    if math.abs(GameRules.GetGameTime()-(RP_timer+delay)) <= ERROR then
        Ability.CastNoTarget(RP)
    end
end

return Magnus