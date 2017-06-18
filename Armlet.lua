-- File： Armlet.lua
-- Author: EroicaCpp (https://github.com/Eroica-cpp/dota2scripts)
-- Version: 3.1
-- Release Date: 2017/6/17

local Utility = require("Utility")

local Armlet = {}

local option = Menu.AddOption({"Item Specific", "Armlet"}, "Auto Toggle", "On/Off")
local optionFarmMode = Menu.AddOption({"Item Specific", "Armlet"}, "Farming Mode", "Toggle on armlet when farming (On/Off)")

local safeThreshold = 550
local dangerousThreshold = 100
local lasttime = GameRules.GetGameTime()
local msg_queue = {}

function Armlet.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(option) then return true end
    if not orders then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end
    if not Utility.IsSuitableToUseItem(myHero) then return true end

    local item = NPC.GetItem(myHero, "item_armlet", true)
    if not item then return true end

    local current = GameRules.GetGameTime()

    -- toggle on armlet if about to attack
    if not Ability.GetToggleState(item) and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET) then
        -- disable auto farm mode if the option is turned off
        if not Menu.IsEnabled(optionFarmMode) and orders.target and NPC.IsCreep(orders.target) then
            return true
        end
        Ability.Toggle(item)
        lasttime = current
    end

    -- toggle off armlet if about to walk
    if Ability.GetToggleState(item) and Entity.GetHealth(myHero) >= safeThreshold and (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET) then
        Ability.Toggle(item)
        lasttime = current
    end

    return true
end

function Armlet.OnUpdate()
    if not Menu.IsEnabled(option) then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToUseItem(myHero) then return end

    local item = NPC.GetItem(myHero, "item_armlet", true)
    if not item then return end

    local current = GameRules.GetGameTime()

    if Entity.GetHealth(myHero) <= dangerousThreshold and current - lasttime > 0.6 then
        Armlet.Toggle()
    end

    if not msg_queue or #msg_queue <= 0 then return end
    local timestamp = table.remove(msg_queue, 1)

    local err = 0.05
    if math.abs(timestamp - current) <= err then
        Ability.Toggle(item)
        lasttime = current
    elseif timestamp > current + err then
        table.insert(msg_queue, timestamp)
    end
end

-- right click from range units (range creep, range hero, tower)
function Armlet.OnProjectile(projectile)
    if not Menu.IsEnabled(option) then return end
    if not projectile or not projectile.source or not projectile.target then return end
    if not projectile.isAttack then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    if projectile.target ~= myHero then return end
    if Entity.IsSameTeam(projectile.source, myHero) then return end

    local true_damage = NPC.GetTrueDamage(projectile.source) * NPC.GetArmorDamageMultiplier(myHero)
    if true_damage + dangerousThreshold >= Entity.GetHealth(myHero) and Entity.GetHealth(myHero) > dangerousThreshold then
        Armlet.Toggle()
    end
end

-- right click from melee units
function Armlet.OnUnitAnimation(animation)
    if not Menu.IsEnabled(option) then return end
    if not animation or not animation.sequenceName or not animation.unit then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end

    if Entity.IsSameTeam(animation.unit, myHero) then return end
    if NPC.IsRanged(animation.unit) then return end
    if not NPC.IsEntityInRange(myHero, animation.unit, 150) then return end

    local true_damage = NPC.GetTrueDamage(animation.unit) * NPC.GetArmorDamageMultiplier(myHero)
    if true_damage + dangerousThreshold >= Entity.GetHealth(myHero) and Entity.GetHealth(myHero) > dangerousThreshold then
        Armlet.Toggle()
    end
end

function Armlet.Toggle()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    local item = NPC.GetItem(myHero, "item_armlet", true)
    if not item then return end

    local current = GameRules.GetGameTime()

    if Ability.GetToggleState(item) then
        table.insert(msg_queue, current)
        table.insert(msg_queue, current+0.1)
    else
        table.insert(msg_queue, current)
    end
end

return Armlet
