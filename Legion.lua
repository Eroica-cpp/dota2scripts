local Utility = require("Utility")

local Legion = {}

Legion.optionOverwhelming = Menu.AddOption({"Hero Specific", "Legion Commander"}, "Overwhelming for KS", "Auto cast overwhelming odds for life steal")
Legion.optionAutoSave = Menu.AddOption({"Hero Specific", "Legion Commander"}, "Auto Save", "Auto cast 'press the attack' to save needed ally")
Legion.optionDuel = Menu.AddOption({"Hero Specific", "Legion Commander"}, "Duel Combo (Extended)", "Extended Duel Combo (e.g., auto break linken's")

function Legion.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_legion_commander" then return end
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return end

    if Menu.IsEnabled(Legion.optionOverwhelming) then
        Legion.OverwhelmingOdds(myHero)
    end

    if Menu.IsEnabled(Legion.optionAutoSave) then
        Legion.PressTheAttack(myHero)
    end
end

function Legion.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(Legion.optionDuel) then return true end
    if not orders or not orders.target then return true end
    if not orders.ability or Ability.GetName(orders.ability) ~= "legion_commander_duel" then return true end


    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_legion_commander" then return true end

    local duel = NPC.GetAbility(myHero, "legion_commander_duel")
    if not duel or not Ability.IsCastable(duel, NPC.GetMana(myHero)) then return true end
    local mana_cost = Ability.GetManaCost(duel)

    local item_blade_mail = NPC.GetItem(myHero, "item_blade_mail", true)
    if item_blade_mail and Ability.IsCastable(item_blade_mail, NPC.GetMana(myHero) - mana_cost) then
        Ability.CastNoTarget(item_blade_mail)
        mana_cost = mana_cost + Ability.GetManaCost(item_blade_mail)
    end

    -- press_the_attack has huge back swing
    -- local press_the_attack = NPC.GetAbility(myHero, "legion_commander_press_the_attack")
    -- if press_the_attack and Ability.IsCastable(press_the_attack, NPC.GetMana(myHero) - mana_cost) then
    --     Ability.CastTarget(press_the_attack, myHero)
    --     mana_cost = mana_cost + Ability.GetManaCost(press_the_attack)
    -- end

    local linken_breaker = NPC.GetItem(myHero, "item_heavens_halberd", true)

    if NPC.IsEntityInRange(myHero, orders.target, Ability.GetCastRange(duel)) then

        if NPC.IsLinkensProtected(orders.target) and linken_breaker
            and Ability.IsCastable(linken_breaker, NPC.GetMana(myHero)) then
            Ability.CastTarget(linken_breaker, orders.target)
        end

        Ability.CastTarget(duel, orders.target)
        return false
    end

    local item_blink = NPC.GetItem(myHero, "item_blink", true)
    if item_blink and Ability.IsCastable(item_blink, NPC.GetMana(myHero))
        and NPC.IsEntityInRange(myHero, orders.target, 1200) then

        Ability.CastPosition(item_blink, Entity.GetAbsOrigin(orders.target))

        if NPC.IsLinkensProtected(orders.target) and linken_breaker
            and Ability.IsCastable(linken_breaker, NPC.GetMana(myHero)) then
            Ability.CastTarget(linken_breaker, orders.target)
        end

        Ability.CastTarget(duel, orders.target)
        return false
    end

    return true
end

-- Auto cast 'press the attack' to save needed ally
function Legion.PressTheAttack(myHero)
    local dispel = NPC.GetAbilityByIndex(myHero, 1)
    if not dispel or not Ability.IsCastable(dispel, NPC.GetMana(myHero)) then return end

    if Utility.NeedToBeSaved(myHero) then
        Ability.CastTarget(dispel, myHero)
        return
    end

    local range = Ability.GetCastRange(dispel)
    local allies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    if not allies or #allies <= 0 then return end

    for i, ally in ipairs(allies) do
        if Utility.NeedToBeSaved(ally) then
            Ability.CastTarget(dispel, ally)
            return
        end
    end
end

-- auto cast overwhelming odds to best position to KS
function Legion.OverwhelmingOdds(myHero)
    local overwhelming = NPC.GetAbilityByIndex(myHero, 0)
    if not overwhelming or not Ability.IsCastable(overwhelming, NPC.GetMana(myHero)) then return end

    local range = Ability.GetCastRange(overwhelming)
    local radius = 330

    local enemies = NPC.GetUnitsInRadius(myHero, range+radius, Enum.TeamType.TEAM_ENEMY)
    if not enemies or #enemies <= 0 then return end

    local num = #enemies
    for i = 1, num do
        for j = i, num do
            if enemies[i] and enemies[j] then
                local vec1 = Entity.GetAbsOrigin(enemies[i])
                local vec2 = Entity.GetAbsOrigin(enemies[j])
                local mid = (vec1 + vec2):Scaled(0.5)

                local damage = Legion.GetOverwhelmingDamage(myHero, overwhelming, mid, radius)
                local lowestHp = Legion.GetLowestHp(myHero, mid, radius)

                if damage >= lowestHp and NPC.IsPositionInRange(myHero, mid, range, 0) then
                    Ability.CastPosition(overwhelming, mid)
                    return
                end
            end
        end -- end of inner loop
    end -- end of outer loop

end -- end of function

function Legion.GetOverwhelmingDamage(myHero, overwhelming, pos, radius)
    if not overwhelming or not pos then return 0 end

    local level = Ability.GetLevel(overwhelming)
    if level <= 0 then return 0 end

    local damage_base = 40 + 20 * (level - 1)
    local damage_per_creep = 14 + 2 * (level - 1)
    local damage_per_hero = 30 * level

    local res = damage_base

    local enemies = NPCs.InRadius(pos, radius, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    for i, enemy in ipairs(enemies) do
        if NPC.IsHero(enemy) and not NPC.IsIllusion(enemy) then
            res = res + damage_per_hero
        else
            res = res + damage_per_creep
        end
    end

    return res
end

function Legion.GetLowestHp(myHero, pos, radius)
    if not myHero or not pos or not radius then return 999999 end

    local lowestHp = 999999
    local enemies = Heroes.InRadius(pos, radius, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    for i, enemy in ipairs(enemies) do
        if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
            local trueHp = Entity.GetHealth(enemy) / math.max(0.01, NPC.GetMagicalArmorDamageMultiplier(enemy))
            lowestHp = math.min(lowestHp, trueHp)
        end
    end

    return lowestHp
end

return Legion