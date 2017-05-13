local Utility = require("Utility")

local Magnus = {}

Magnus.optionAwareness = Menu.AddOption({"Hero Specific", "Magnus"}, "Killable Awareness", "show how many hits left (with the damage of shockwave) to kill an enemy")
Magnus.optionKillSteal = Menu.AddOption({"Hero Specific", "Magnus"}, "Kill Steal", "auto cast shockwave to KS")
Magnus.optionEmpower = Menu.AddOption({"Hero Specific", "Magnus"}, "Auto Empower", "auto cast empower on allies or magnus himself")
Magnus.optionRPHelper = Menu.AddOption({"Hero Specific", "Magnus"}, "RP Helper", "Auto blink to best position for RP, auto turn around before RP")
Magnus.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

local RP_timer
local ERROR = 0.05

-- show how many hits left (with the damage of shockwave) to kill an enemy
function Magnus.OnDraw()
    if not Menu.IsEnabled(Magnus.optionAwareness) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_magnataur" then return end

    local wave = NPC.GetAbility(myHero, "magnataur_shockwave")
    local level = Ability.GetLevel(wave)
    local wave_damage = 75 * level
    if not Ability.IsCastable(wave, NPC.GetMana(myHero)) then wave_damage = 0 end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
            local enemyHp = Entity.GetHealth(enemy)
            local physicalDamage = NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
            local magicalDamage = wave_damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            local hitsLeft = math.ceil((enemyHp - magicalDamage) / (physicalDamage + 1))
        
            -- draw
            local pos = Entity.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)

            -- red : can kill; green : cant kill
            if enemyHp - magicalDamage <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(Magnus.font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
                Renderer.DrawTextCentered(Magnus.font, x, y, hitsLeft, 1)
            end
        end
    end
end

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

    if Menu.IsEnabled(Magnus.optionKillSteal) then
        Magnus.KillSteal(myHero)
    end

    if Menu.IsEnabled(Magnus.optionEmpower) then
        Magnus.AutoEmpower(myHero)
    end

    if Menu.IsEnabled(Magnus.optionRPHelper) then
        Magnus.RPHelper(myHero)
    end
end

-- auto cast shockwave to KS
function Magnus.KillSteal(myHero)
    local wave = NPC.GetAbility(myHero, "magnataur_shockwave")
    if not wave or not Ability.IsCastable(wave, NPC.GetMana(myHero)) then return end

    local level = Ability.GetLevel(wave)
    local wave_damage = 75 * level

    local range = 1150
    local enemiesAround = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)

    for i, enemy in ipairs(enemiesAround) do
        local magicalDamage = wave_damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
        if Entity.GetHealth(enemy) <= magicalDamage and not NPC.IsIllusion(enemy) and Entity.IsAlive(enemy)
            and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) 
            and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then

            local dis = (Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(myHero)):Length()
            local speed = 1150
            local travel_time = dis / (speed + 1)
            local castpoint = 0.3
            local delay = travel_time + castpoint

            local pos = Utility.GetPredictedPosition(enemy, delay)
            if (pos - Entity.GetAbsOrigin(myHero)):Length() <= range then
                Ability.CastPosition(wave, pos)
                return
            end
        end
    end
end

-- auto cast empower on himself or needed ally heroes
-- priority: magnus -> melee ally hero -> ranged ally hero
function Magnus.AutoEmpower(myHero)
    local empower = NPC.GetAbilityByIndex(myHero, 1)
    if not empower or not Ability.IsCastable(empower, NPC.GetMana(myHero)) then return end

    -- avoid cancel right click when farming
    if NPC.IsAttacking(myHero) then return end

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
    -- for i, ally in ipairs(alliesAround) do
    --     if not NPC.HasModifier(ally, "modifier_magnataur_empower") and not NPC.IsIllusion(ally) then
    --         Ability.CastTarget(empower, ally)
    --         return
    --     end
    -- end
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