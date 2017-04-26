local Armlet = {}

local option = Menu.AddOption({"Item Specific"}, "Armlet", "Auto toggle armlet")

local HpThreshold = 550

function Armlet.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(option) then return true end
    if not orders then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end

    local item = NPC.GetItem(myHero, "item_armlet", true)
    if not item then return true end

    -- toggle on armlet if about to attack
    if not Ability.GetToggleState(item) and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET) then
        Ability.Toggle(item)
    end

    -- toggle off armlet if about to walk
    if Ability.GetToggleState(item) and Entity.GetHealth(myHero) >= HpThreshold and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET) then
        Ability.Toggle(item)
    end

    return true
end

return Armlet