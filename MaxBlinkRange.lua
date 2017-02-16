local MBR = {}

MBR.option = Menu.AddOption({ "Utility" }, "Max Blink Range", "Blink's 1200 units if you try to blink outside the normal range")

function MBR.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(MBR.option) then return true end
 
    if orders.order ~= Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION then return true end
    if not orders.ability then return true end
    if not orders.npc then return true end

    if Ability.GetName(orders.ability) ~= "item_blink" then return true end

    local castRange = Ability.GetLevelSpecialValueFor(orders.ability, "blink_range") + NPC.GetCastRangeBonus(orders.npc)
    
    if NPC.IsPositionInRange(orders.npc, orders.position, castRange, 0) then return true end

    local origin = NPC.GetAbsOrigin(orders.npc)
    local dir = orders.position - origin

    dir:SetZ(0)
    dir:Normalize()
    dir:Scale(castRange - 1)

    local pos = origin + dir

    Player.PrepareUnitOrders(orders.player, orders.order, orders.target, pos, orders.ability, orders.orderIssuer, orders.npc, orders.queue, orders.showEffects)

    return false
end

return MBR
