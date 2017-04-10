local TranquilBoots = {}

local optionSwitch = Menu.AddOption({"Item Specific", "Tranquil Boots"}, "Auto Switch", "auto put the boot on backpack when attack no-hero unit, otherwise put it back to inventory")
local optionEnableKey = Menu.AddOption({"Item Specific", "Tranquil Boots"}, "Enable Key", "tap one key to put tranquil boot to backpack; tap again to put it back to inventory")
local key = Menu.AddKeyOption({"Item Specific", "Tranquil Boots"}, "Key", Enum.ButtonCode.KEY_TAB)

function TranquilBoots.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(optionSwitch) then return true end
    if not orders or not orders.order then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end

    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET then
        local radius = 600
        local units = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
        if not units or #units <= 0 then
            TranquilBoots.Switch2Inventory(myHero)
        end
    end

    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET then
        if orders.target and not NPC.IsHero(orders.target) then
            TranquilBoots.Switch2Backpack(myHero)
        end
    end

    return true
end


function TranquilBoots.OnUpdate()
    if not Menu.IsEnabled(optionEnableKey) or not Menu.IsKeyDownOnce(key) then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    TranquilBoots.Switch2Backpack(myHero)
    TranquilBoots.Switch2Inventory(myHero)
end

function TranquilBoots.Switch2Backpack(myHero)
    for i = 0, 5 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and Ability.GetName(item) == "item_tranquil_boots" then
            if i <= 2 then TranquilBoots.MoveItemToSlot(myHero, item, i+6); return end
            if i >= 3 then TranquilBoots.MoveItemToSlot(myHero, item, i+3); return end
        end
    end
end

function TranquilBoots.Switch2Inventory(myHero)
    for i = 6, 8 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and Ability.GetName(item) == "item_tranquil_boots" then
            TranquilBoots.MoveItemToSlot(myHero, item, i-3); return
        end
    end
end

function TranquilBoots.MoveItemToSlot(myHero, item, slot_index)
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, slot_index, Vector(0, 0, 0), item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

return TranquilBoots