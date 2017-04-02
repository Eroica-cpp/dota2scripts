local Utility = require("Utility")

local Enigma = {}

Enigma.optionMidnightPulse = Menu.AddOption({"Hero Specific", "Enigma"}, "Auto Midnight Pulse", "auto cast midnight pulse before black hole")

-- auto cast midnight pulse before black hole
function Enigma.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(Enigma.optionMidnightPulse) then return true end
    if not orders or not orders.ability then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    if not Entity.IsAbility(orders.ability) then return true end
    if Ability.GetName(orders.ability) ~= "enigma_black_hole" then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if (not Entity.IsAlive(myHero)) or NPC.IsStunned(myHero) then return true end

    local pulse = NPC.GetAbilityByIndex(myHero, 2)
    if not pulse or not Ability.IsCastable(pulse, NPC.GetMana(myHero)-Ability.GetManaCost(orders.ability)) then return true end

    if not orders.position then return true end
    Ability.CastPosition(pulse, orders.position)

    return true
end

return Enigma