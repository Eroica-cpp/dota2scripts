local AutoStash = {}

AutoStash.optionEnable = Menu.AddOption({ "Utility", "Auto Stash Item" }, "Enable", "Auto stash items when in base")

AutoStash.dontStashList = {
    item_aegis = true,
    item_soul_ring = true,
    item_rapier = true,
    item_tpscroll = true,
    item_wind_lace = true,
    item_boots = true,
    item_tranquil_boots = true,
    item_phase_boots = true,
    item_travel_boots = true,
    item_travel_boots_2 = true,
    item_quelling_blade = true,
    item_iron_talon = true,
    item_blink = true,
    item_infused_raindrop = true,
    item_bottle = true,
    item_faerie_fire = true,
    item_flask = true, -- healing salve
    item_clarity = true,
    item_tango = true,
    item_tango_single = true,
    item_enchanted_mango = true,
    item_smoke_of_deceit = true,
    item_dust = true,
    item_ward_observer = true,
    item_ward_sentry = true,
    item_recipe_ward_dispenser = true,
    item_ward_dispenser = true,
    item_gem = true,
    item_hand_of_midas = true,
    item_stout_shield = true,
    item_poor_mans_shield = true
}

-- stash items when (1) using soul ring in base; (2) using bottle in base
function AutoStash.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(AutoStash.optionEnable) then return true end
    if not orders or not orders.ability then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end

    if Entity.IsAbility(orders.ability) 
        and Ability.GetName(orders.ability) == "item_soul_ring"
        and NPC.HasModifier(myHero, "modifier_fountain_aura_buff") then
        
        AutoStash.inventory2stash(myHero)
    end

    if Entity.IsAbility(orders.ability) 
        and Ability.GetName(orders.ability) == "item_bottle"
        and NPC.HasModifier(myHero, "modifier_fountain_aura_buff") then
        
        AutoStash.inventory2stash(myHero)
    end

    return true
end

function AutoStash.OnUpdate()
    if not Menu.IsEnabled(AutoStash.optionEnable) then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    -- move items back to inventory afer using soul ring
    if NPC.HasModifier(myHero, "modifier_fountain_aura_buff") 
        and NPC.HasModifier(myHero, "modifier_item_soul_ring_buff") then

        local mod = NPC.GetModifier(myHero, "modifier_item_soul_ring_buff")
        if GameRules.GetGameTime() - Modifier.GetCreationTime(mod) > 0.1 then
            AutoStash.stash2inventory(myHero)
        end
    end

    -- move items back to inventory afer using bottle
    if NPC.HasModifier(myHero, "modifier_fountain_aura_buff") 
        and NPC.HasModifier(myHero, "modifier_bottle_regeneration") then

        local mod = NPC.GetModifier(myHero, "modifier_bottle_regeneration")
        if GameRules.GetGameTime() - Modifier.GetCreationTime(mod) > 0.5 then
            AutoStash.stash2inventory(myHero)
        end
    end

    -- when healed by shrine
    if NPC.HasModifier(myHero, "modifier_filler_heal") then
        local enemyUnits = NPC.GetHeroesInRadius(myHero, 1000, Enum.TeamType.TEAM_ENEMY)
        local mod = NPC.GetModifier(myHero, "modifier_filler_heal")
        if #enemyUnits <= 0 and GameRules.GetGameTime()-Modifier.GetCreationTime(mod) < 0.1 then
            AutoStash.tmpMoveItem2Backpack(myHero)
        end
    end

end

function AutoStash.tmpMoveItem2Backpack(myHero)
    local tmp_slot = 8
    for i = 0, 5 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item then
            local itemName = Ability.GetName(item)
            if not AutoStash.dontStashList[itemName] then
                AutoStash.moveItemToSlot(myHero, item, tmp_slot)
                AutoStash.moveItemToSlot(myHero, item, i)
            end
        end 
    end
end

function AutoStash.inventory2stash(myHero)
    local delta = 9
    for i = 0, 5 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and not NPC.GetItemByIndex(myHero, i+delta) then
            local itemName = Ability.GetName(item)
            if not AutoStash.dontStashList[itemName] then
                AutoStash.moveItemToSlot(myHero, item, i+delta)
            end
        end
    end
end

function AutoStash.stash2inventory(myHero)
    local delta = 9
    for i = 9, 14 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item and not NPC.GetItemByIndex(myHero, i-delta) then
            AutoStash.moveItemToSlot(myHero, item, i-delta)
        end
    end
end

function AutoStash.moveItemToSlot(myHero, item, slot_index)
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, slot_index, Vector(0, 0, 0), item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

return AutoStash