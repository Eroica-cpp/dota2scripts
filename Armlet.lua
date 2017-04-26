local Utility = require("Utility")

local Armlet = {}

local option = Menu.AddOption({"Item Specific"}, "Armlet", "Auto toggle armlet")

local safeThreshold = 550
local dangerousThreshold = 200

function Armlet.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(option) then return true end
    if not orders then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if not Utility.IsSuitableToUseItem(myHero) then return true end

    local item = NPC.GetItem(myHero, "item_armlet", true)
    if not item then return true end

    -- toggle on armlet if about to attack
    if not Ability.GetToggleState(item) and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET) then
        Ability.Toggle(item)
    end

    -- toggle off armlet if about to walk
    if Ability.GetToggleState(item) and Entity.GetHealth(myHero) >= safeThreshold and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET) then
        Ability.Toggle(item)
    end

    return true
end

-- function Armlet.OnUpdate()
--     if not Menu.IsEnabled(option) then return end

--     local myHero = Heroes.GetLocal()
--     if not myHero then return end

--     local item = NPC.GetItem(myHero, "item_armlet", true)
--     if not item then return end

--     local delay = 0.6
--     local mod = NPC.GetModifier(myHero, "modifier_item_armlet_unholy_strength")

--     if Entity.GetHealth(myHero) <= dangerousThreshold then
--         -- if doesn't toggle, then toggle armlet
--         if not mod then Ability.Toggle(item); return end
        
--         -- if does toggled, toggle it again after 0.6 second
--         if math.abs(GameRules.GetGameTime() - Modifier.GetCreationTime(mod) - delay) <= 0.05 then
--             Ability.Toggle(item)
--             Ability.Toggle(item)
--         end
--     end
-- end

return Armlet