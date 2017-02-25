local AutoStash = {}

AutoStash.optionEnable = Menu.AddOption({ "Utility", "Auto Stash Item" }, "Enable", "Auto stash items when in base")

AutoStash.dontStashList = {
    item_aegis = true,
    item_soul_ring = true,
    item_rapier = true,
    item_tpscroll = true,
    item_travel_boots = true,
    item_travel_boots_2 = true,
    item_blink = true,
    item_bottle = true
}

local hasStashed = false

function AutoStash.OnUpdate()
	if not Menu.IsEnabled(AutoStash.optionEnable) then return end
	
    local myHero = Heroes.GetLocal()
    if not isInFountain(myHero) then return end

    local tp = NPC.GetItem(myHero, "item_tpscroll", true)
    local tp_boot_1 = NPC.GetItem(myHero, "item_travel_boots", true)
    local tp_boot_2 = NPC.GetItem(myHero, "item_travel_boots_2", true)

    local isTping = false
    isTping = tp and (isTping or Ability.IsChannelling(tp)) or isTping
    isTping = tp_boot_1 and (isTping or Ability.IsChannelling(tp_boot_1)) or isTping
    isTping = tp_boot_2 and (isTping or Ability.IsChannelling(tp_boot_2)) or isTping
    
    if isTping and hasStashed then
        stash2inventory(myHero)
        hasStashed = false
    end

    if not isTping and not hasStashed then
        inventory2stash(myHero)
        hasStashed = true
    end
end

function inventory2stash(myHero)
    local delta = 9
    for i = 0, 5 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and not NPC.GetItemByIndex(myHero, i+delta) then
            local itemName = Ability.GetName(item)
            if not AutoStash.dontStashList[itemName] then
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

function isInFountain(myHero)
    local radius = 900
    for i, npc in ipairs(NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_FRIEND)) do
        if NPC.GetUnitName(npc) == "dota_fountain" then return true end
    end
    return false
end

return AutoStash