local Utility = require("Utility")

local Storm = {}

local optionAutoRemnant = Menu.AddOption({"Hero Specific", "Storm Spirit"}, "Auto Remnant", "Auto cast remnant if there's an enemy in range")
local optionAutoVortex = Menu.AddOption({"Hero Specific", "Storm Spirit"}, "Auto Vortex", "Auto vortex any enemy in range")
local optionAttackHelper = Menu.AddOption({"Hero Specific", "Storm Spirit"}, "Attack Helper", "When right click enemy, auto bolt to maximize damage")

local target
local timer = GameRules.GetGameTime()

function Storm.OnPrepareUnitOrders(orders)
    if not orders then return true end
    target = orders.target
    return true
end

function Storm.OnUpdate()
    if Menu.IsEnabled(optionAutoRemnant) then
        Storm.AutoRemnant()
    end

    if Menu.IsEnabled(optionAutoVortex) then
        Storm.AutoVortex()
    end

    if Menu.IsEnabled(optionAttackHelper) then
        Storm.AttackHelper()
    end
end

function Storm.AutoRemnant()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "storm_spirit_static_remnant")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local radius = 200 -- 235, 260

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, radius) then

            Ability.CastNoTarget(spell)
            return
        end
    end
end

function Storm.AutoVortex()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "storm_spirit_electric_vortex")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsDisabled(enemy) and not NPC.IsLinkensProtected(enemy) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

function Storm.AttackHelper()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "storm_spirit_ball_lightning")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    if not target or Entity.IsSameTeam(myHero, target) or not Entity.IsHero(target) then return end
    if not Utility.CanCastSpellOn(target) then return end

    local radius = 120 -- 30 + 30 * Ability.GetLevel(spell)
    local dir = Entity.GetAbsRotation(target):GetForward():Normalized()
    local front_pos = Entity.GetAbsOrigin(target) + dir:Scaled(radius)
    local back_pos = Entity.GetAbsOrigin(target) - dir:Scaled(radius)

    if (GameRules.GetGameTime() - timer) > NPC.GetAttackTime(myHero) + Ability.GetCastPoint(spell) + 0.15
    and (not NPC.IsEntityInRange(myHero, target, NPC.GetAttackRange(myHero))
    or not NPC.HasModifier(myHero, "modifier_storm_spirit_overload_debuff")) then

        if (Entity.GetAbsOrigin(myHero) - back_pos):Length() >= radius then
            Ability.CastPosition(spell, back_pos)
        else
            Ability.CastPosition(spell, front_pos)
        end

        timer = GameRules.GetGameTime()
    end

    Player.AttackTarget(Players.GetLocal(), myHero, target)
end

return Storm
