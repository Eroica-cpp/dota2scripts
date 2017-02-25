local oneKeyStash = {}

oneKeyStash.optionEnable = Menu.AddOption({ "Utility", "One Key Stash Item" }, "Enable", "Put your Item to base stash")
oneKeyStash.optionKey = Menu.AddKeyOption({ "Utility","One Key Stash Item"}, "Key",Enum.ButtonCode.KEY_T)

oneKeyStash.itemList = {
    item_dagon_1= true, 
    item_dagon_2 = true, 
    item_dagon_3 = true, 
    item_dagon_4 = true, 
    item_dagon_5 = true,
    item_ethereal_blade = true,
    item_mystic_staff = true,
    item_ogre_axe = true,
    item_point_booster = true,
    item_staff_of_wizardry = true,
    item_ultimate_orb = true,
    item_aether_lens = true,
    item_ultimate_scepter = true,
    item_cyclone = true,
    item_ancient_janggo = true,
    item_force_staff = true,
    item_magic_wand = true,
    item_null_talisman = true,
    item_rod_of_atos = true
}

oneKeyStash.itemOrderStash = {}
oneKeyStash.itemOrderDrop ={}
oneKeyStash.isStashing = true

function oneKeyStash.OnUpdate()
	if not Menu.IsEnabled(oneKeyStash.optionEnable) then return end
	if not Menu.IsKeyDownOnce(oneKeyStash.optionKey) then return end

	local myHero = Heroes.GetLocal()
    -- false for NPC.GetItem means it will search for items in inventory, backpack, AND stash.

    local boots = NPC.GetItem(myHero,"item_boots")
    if oneKeyStash.isStashing then
        if NPC.HasModifier(myHero, "modifier_fountain_aura_buff") then 
            oneKeyStash.stashItem(myHero)
        else
            oneKeyStash.dropItem(myHero)
        end 
    else
        if NPC.HasModifier(myHero, "modifier_fountain_aura_buff") then 
            oneKeyStash.getItem(myHero)
        else 
            oneKeyStash.pickItem(myHero)
        end 
    end 
end


function oneKeyStash.dropItem(myHero)
    for i = 0, 9 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item then 
            local name = Ability.GetName(item)
            --Log.Write(name..i)
            if oneKeyStash.itemList[name] then
                --Log.Write(name)
                local vector = NPC.GetAbsOrigin(myHero)
                oneKeyStash.itemOrderDrop[name] = {item, i, vector}
                oneKeyStash.DropItem(myHero, item, vector)
            end 
        end 
    end 
    oneKeyStash.isStashing = false
end

function oneKeyStash.pickItem(myHero)
    for k, v in pairs(oneKeyStash.itemOrderDrop) do
        local item = v[1]
        local slot = v[2]
        local vector = v[3]
        Log.Write(k)
        oneKeyStash.PickItem(myHero, item, NPC.GetAbsOrigin(myHero), 1)
        oneKeyStash.MoveItemToSlot(myHero, item, slot)
    end
    oneKeyStash.isStashing = true
end

function oneKeyStash.stashItem(myHero)
    for i = 0, 9 do
        local item = NPC.GetItemByIndex(myHero, i)
        if item then 
            local name = Ability.GetName(item)
            --Log.Write(name..i)
            if oneKeyStash.itemList[name] then
                --Log.Write(name)
                oneKeyStash.itemOrderStash[name] = {item, i}
                oneKeyStash.MoveItemToSlot(myHero, item, i+6)
            end 
        end 
    end 
    oneKeyStash.isStashing = false
end

function oneKeyStash.getItem(myHero)
    for k, v in pairs(oneKeyStash.itemOrderStash) do
        local item = v[1]
        oneKeyStash.MoveItemToSlot(myHero, item, v[2])
    end
    oneKeyStash.isStashing = true
end

function oneKeyStash.MoveItemToSlot(unit, item, slot)
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, slot, Vector(0, 0, 0), item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
end

function oneKeyStash.DropItem(unit, item, vector)
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_DROP_ITEM, slot, vector, item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
end 

function oneKeyStash.PickItem(unit, item, vector, slot)
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM, slot, vector, item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
end 

return oneKeyStash