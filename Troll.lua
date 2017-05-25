local Troll = {}

local optionAutoSwap = Menu.AddOption({"Hero Specific", "Troll Warlord"}, "Auto Swap", "Auto Swap between range and melee")
local optionEnableKey = Menu.AddOption({"Hero Specific", "Troll Warlord"}, "Enable Key", "On/Off")
local keyAxeMelee = Menu.AddKeyOption({"Hero Specific", "Troll Warlord"}, "Whirling Axe (Melee) Key", Enum.ButtonCode.KEY_W)
local keyAxeRanged = Menu.AddKeyOption({"Hero Specific", "Troll Warlord"}, "Whirling Axes (Ranged) Key", Enum.ButtonCode.KEY_E)

function Troll.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(optionAutoSwap) then return true end
    if not orders then return true end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_troll_warlord" then return true end
    if NPC.IsStunned(myHero) or NPC.IsSilenced(myHero) then return true end

    local swap = NPC.GetAbilityByIndex(myHero, 0)
    if not swap or not Ability.IsCastable(swap, 0) then return true end

    -- swap to melee when running
    if not Ability.GetToggleState(swap) and 
        (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION 
            or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET 
            or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE) 
        then
        Ability.Toggle(swap, true)
        return true
    end

    -- auto swap between melee and range
    local melee_attack_range = 150
    local range = melee_attack_range + 100
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET then
        if NPC.IsEntityInRange(myHero, orders.target, range) and not Ability.GetToggleState(swap) then
            Ability.Toggle(swap, true)
            return true
        end

        if not NPC.IsEntityInRange(myHero, orders.target, range) and Ability.GetToggleState(swap) then
            Ability.Toggle(swap, true)
            return true
        end
    end

    return true
end

function Troll.OnUpdate()
    if not Menu.IsEnabled(optionEnableKey) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_troll_warlord" then return end

    local swap = NPC.GetAbility(myHero, "troll_warlord_berserkers_rage")
    local axe_melee = NPC.GetAbility(myHero, "troll_warlord_whirling_axes_melee")
    local axe_ranged = NPC.GetAbility(myHero, "troll_warlord_whirling_axes_ranged")    

    -- melee axe
    if Menu.IsKeyDownOnce(keyAxeMelee) and Ability.IsCastable(axe_melee, NPC.GetMana(myHero)) then
        if swap and not Ability.GetToggleState(swap) then 
            Ability.Toggle(swap) 
            Ability.CastNoTarget(axe_melee)
            Ability.Toggle(swap)
        else
            Ability.CastNoTarget(axe_melee)
        end
    end

    -- ranged axe
    if Menu.IsKeyDownOnce(keyAxeRanged) and Ability.IsCastable(axe_ranged, NPC.GetMana(myHero)) then
        if swap and Ability.GetToggleState(swap) then 
            Ability.Toggle(swap) 
            Ability.CastPosition(axe_ranged, Input.GetWorldCursorPos())
            Ability.Toggle(swap)
        else
            Ability.CastPosition(axe_ranged, Input.GetWorldCursorPos())
        end
    end
end

return Troll