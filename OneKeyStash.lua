local oneKeyStash = {}

oneKeyStash.optionEnable = Menu.AddOption({ "Utility", "One Key Stash Item" }, "Enable", "Put your Item to base stash")
oneKeyStash.optionKey = Menu.AddKeyOption({ "Utility","One Key Stash Item"}, "Key",Enum.ButtonCode.KEY_T)

oneKeyStash.dontStashList = {
    item_aegis = true,
    item_soul_ring = true,
    item_rapier = true,
    item_tpscroll = true,
    item_travel_boots = true,
    item_travel_boots_2 = true,
    item_blink = true
}

-- mutex is true  => to put items to stash
-- mutex is false => to put items to inventory
local mutex = true

function oneKeyStash.OnUpdate()
	if not Menu.IsEnabled(oneKeyStash.optionEnable) then return end
	if not Menu.IsKeyDownOnce(oneKeyStash.optionKey) then return end

    local myHero = Heroes.GetLocal()
    if not NPC.HasModifier(myHero, "modifier_fountain_aura_buff") then return end

    if mutex then
        inventory2stash(myHero)
        mutex = not mutex
    else
        stash2inventory(myHero)
        mutex = not mutex
    end

end

function inventory2stash(myHero)
    local delta = 9
    for i = 0, 5 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and not NPC.GetItemByIndex(myHero, i+delta) then
            local itemName = Ability.GetName(item)
            if not oneKeyStash.dontStashList[itemName] then
                moveItemToSlot(myHero, item, i+delta)
            end
        end
    end
end

function stash2inventory(myHero)
    local delta = 9
    for i = 9, 14 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and not NPC.GetItemByIndex(myHero, i-delta) then
            moveItemToSlot(myHero, item, i-delta)
        end
    end
end

function moveItemToSlot(myHero, item, slot_index)
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, slot_index, Vector(0, 0, 0), item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

return oneKeyStash