local Utility = require("Utility")

local Lion = {}

local optionAutoHex = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Hex", "Auto hex any enemy in range once lion has level 6")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Lion"}, "Auto KS (upgraded version)", "Auto kill steal using finger of death and/or ethereal blade.")
local optionKillStealCounter = Menu.AddOption({"Hero Specific", "Lion"}, "Show KS Counter", "Show how many hits remains to kill steal.")
local optionAutoSpike = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Spike", "Auto spike if enemy is (1) TPing; (2) channelling; or (3) stunned/hexed/rooted/taunted with proper timing")
local optionSpikeRangeHelper = Menu.AddOption({"Hero Specific", "Lion"}, "Spike Range Helper", "Help to cast spike if the target is within spike travel distance but out of cast range")
local optionAutoManaDrain = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Mana Drain", "Auto mana drain to break (1) linken (or AM's shell); (2) illusion")

local KS_target
local KS_time
local cast_point = 0.3 -- the cast point of finger of death

local spell_damage_table = {}

function Lion.OnUpdate()
    if Menu.IsEnabled(optionAutoHex) then
        Lion.AutoHex()
    end

    if Menu.IsEnabled(optionKillSteal) then
        Lion.KillSteal()
        Lion.KillStealHelper()
    end

    if Menu.IsEnabled(optionAutoSpike) then
        Lion.AutoSpike()
    end

    if Menu.IsEnabled(optionAutoManaDrain) then
        Lion.AutoManaDrain()
    end
end

function Lion.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(optionSpikeRangeHelper) then return true end

    local myHero = Heroes.GetLocal()
    if not myHero then return true end

    if not orders or not orders.ability then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    if not Entity.IsAbility(orders.ability) then return true end
    if Ability.GetName(orders.ability) ~= "lion_impale" then return true end

    local range = Ability.GetCastRange(orders.ability)
    if not orders.target and not orders.position then return true end
    if orders.target and NPC.IsEntityInRange(myHero, orders.target, range) then return true end
    if orders.position and NPC.IsPositionInRange(myHero, orders.position, range) then return true end

    -- reference: https://dota2.gamepedia.com/Lion
    -- real range = travel distance + radius
    local real_range = range + 325 + 125
    local target_position
    if orders.target and Entity.IsNPC(orders.target) then
        target_position = Entity.GetAbsOrigin(orders.target)
    else
        target_position = orders.position
    end

    local direction = (target_position - Entity.GetAbsOrigin(myHero)):Normalized()
    local cast_position
    if NPC.IsPositionInRange(myHero, target_position, real_range) then
        cast_position = Entity.GetAbsOrigin(myHero) + direction:Scaled(range)
    else
        cast_position = Entity.GetAbsOrigin(myHero) + direction:Scaled(range + (target_position-Entity.GetAbsOrigin(myHero)):Length() - real_range)
    end

    Ability.CastPosition(orders.ability, cast_position)
    return false
end

-- show how many hits left to KS
function Lion.OnDraw()
    if not Menu.IsEnabled(optionKillStealCounter) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_lion" then return end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and spell_damage_table[NPC.GetUnitName(enemy)] 
            and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local oneHitDamage = NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)

            local hitsLeft = -1
            if NPC.GetCurrentLevel(myHero) >= 6 then
                hitsLeft = math.ceil((Entity.GetHealth(enemy) - spell_damage_table[NPC.GetUnitName(enemy)]) / oneHitDamage)
            else
                hitsLeft = math.ceil(Entity.GetHealth(enemy) / oneHitDamage)
            end

            -- draw
            local pos = Entity.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)
            local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

            -- red : can kill; green : cant kill
            if not Utility.IsDiskProtected(enemy) then
                if hitsLeft <= 0 then
                    Renderer.SetDrawColor(255, 0, 0, 255)
                    Renderer.DrawTextCentered(font, x, y, "Kill", 1)
                else
                    Renderer.SetDrawColor(0, 255, 0, 255)
                    Renderer.DrawTextCentered(font, x, y, hitsLeft, 1)
                end
            else
                if hitsLeft <= 0 then
                    Renderer.SetDrawColor(0, 255, 0, 255)
                    Renderer.DrawTextCentered(font, x, y, "Kill (Disk)", 1)
                else
                    Renderer.SetDrawColor(0, 255, 0, 255)
                    Renderer.DrawTextCentered(font, x, y, hitsLeft .. " (Disk)", 1)
                end
            end
        end
    end
end

-- KS using finger of death together with ethereal blade
function Lion.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "lion_finger_of_death")
    if not spell then return end
    local range = Ability.GetCastRange(spell)

    local base_damage = 0
    if Ability.IsCastable(spell, NPC.GetMana(myHero)) then
        if NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
            base_damage = 725 + 150 * (Ability.GetLevel(spell) - 1)
        else
            base_damage = 600 + 125 * (Ability.GetLevel(spell) - 1)
        end
    end

    local additional_damage = 0
    local mod = NPC.GetModifier(myHero, "modifier_lion_finger_of_death_kill_counter")
    if mod and Ability.IsCastable(spell, NPC.GetMana(myHero)) then
        kill_counter = Modifier.GetStackCount(mod)
        if NPC.GetCurrentLevel(myHero) >= 20 then
            additional_damage = 60 * kill_counter
        else
            additional_damage = 40 * kill_counter
        end
    end
    local finger_damage = base_damage + additional_damage

    local dagon, dagon_level
    local dagon1 = NPC.GetItem(myHero, "item_dagon", true)
    local dagon2 = NPC.GetItem(myHero, "item_dagon_2", true)
    local dagon3 = NPC.GetItem(myHero, "item_dagon_3", true)
    local dagon4 = NPC.GetItem(myHero, "item_dagon_4", true)
    local dagon5 = NPC.GetItem(myHero, "item_dagon_5", true)
    if dagon1 and Ability.IsCastable(dagon1, NPC.GetMana(myHero)) then dagon = dagon1; dagon_level = 1 end
    if dagon2 and Ability.IsCastable(dagon2, NPC.GetMana(myHero)) then dagon = dagon2; dagon_level = 2 end
    if dagon3 and Ability.IsCastable(dagon3, NPC.GetMana(myHero)) then dagon = dagon3; dagon_level = 3 end
    if dagon4 and Ability.IsCastable(dagon4, NPC.GetMana(myHero)) then dagon = dagon4; dagon_level = 4 end
    if dagon5 and Ability.IsCastable(dagon5, NPC.GetMana(myHero)) then dagon = dagon5; dagon_level = 5 end

    local dagon_damage = 0
    if dagon and Ability.IsCastable(dagon, NPC.GetMana(myHero)) then
        dagon_damage = 400 + 100 * (dagon_level - 1)
        range = math.min(range, Ability.GetCastRange(dagon))
    end

    local total_damage = finger_damage + dagon_damage

    local ethereal_base_damage = 0
    local ethereal_amplified_damage = 0
    local item = NPC.GetItem(myHero, "item_ethereal_blade", true)
    if item and Ability.IsCastable(item, NPC.GetMana(myHero)) then
        ethereal_base_damage = 125 + 1.5 * Hero.GetIntellectTotal(myHero)
        ethereal_amplified_damage = 0.4 * total_damage
        range = math.min(range, Ability.GetCastRange(item))
    end 

    local indices = Utility.GetHeroIndicesOrderedByLevel()
    for k, v in ipairs(indices) do
        local enemy = Heroes.Get(v)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and Utility.IsKillable(enemy) then

            local true_damage = Utility.GetRealDamage(myHero, enemy, total_damage)
            spell_damage_table[NPC.GetUnitName(enemy)] = true_damage

            -- if true_damage >= Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point and Utility.IsSafeToCast(myHero, enemy, true_damage)
            if Utility.CanCastSpellOn(enemy) and not Utility.IsLinkensProtected(enemy) and not Utility.IsDiskProtected(enemy)
                -- and NPC.IsEntityInRange(myHero, enemy, range) and Ability.IsCastable(spell, NPC.GetMana(myHero))
                and (not KS_target or NPC.GetUnitName(KS_target) == NPC.GetUnitName(enemy)) then

                local dagon_true_damage = Utility.GetRealDamage(myHero, enemy, dagon_damage)
                if Entity.GetHealth(enemy) < dagon_true_damage and Utility.IsSafeToCast(myHero, enemy, dagon_true_damage)
                    and NPC.IsEntityInRange(myHero, enemy, Ability.GetCastRange(dagon))
                    and Ability.IsCastable(dagon, NPC.GetMana(myHero)) then
                    Ability.CastTarget(dagon, enemy)
                    return
                end

                local finger_true_damage = Utility.GetRealDamage(myHero, enemy, finger_damage)
                if Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point < finger_true_damage
                    and Utility.IsSafeToCast(myHero, enemy, finger_true_damage)
                    and NPC.IsEntityInRange(myHero, enemy, Ability.GetCastRange(spell))
                    and Ability.IsCastable(spell, NPC.GetMana(myHero)) then
                    Ability.CastTarget(spell, enemy)
                    return
                end

                if Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point < true_damage
                    and Utility.IsSafeToCast(myHero, enemy, true_damage)
                    and NPC.IsEntityInRange(myHero, enemy, range)
                    and Ability.IsCastable(dagon, NPC.GetMana(myHero) - Ability.GetManaCost(spell))
                    and Ability.IsCastable(spell, NPC.GetMana(myHero) - Ability.GetManaCost(dagon)) then
                    Ability.CastTarget(dagon, enemy)
                    Ability.CastTarget(spell, enemy)
                    return
                end
            end

            if item and Ability.IsCastable(item, NPC.GetMana(myHero)) then

                true_damage = Utility.GetRealDamage(myHero, enemy, total_damage + ethereal_base_damage + ethereal_amplified_damage)
                spell_damage_table[NPC.GetUnitName(enemy)] = true_damage

                if true_damage >= Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*cast_point and Utility.IsSafeToCast(myHero, enemy, true_damage)
                    and Utility.CanCastSpellOn(enemy) and not Utility.IsLinkensProtected(enemy) and not Utility.IsDiskProtected(enemy)
                    and NPC.IsEntityInRange(myHero, enemy, range)
                    and ((spell and Ability.IsCastable(spell, NPC.GetMana(myHero) - Ability.GetManaCost(item)))
                        or (dagon and Ability.IsCastable(dagon, NPC.GetMana(myHero) - Ability.GetManaCost(item)))) then

                    Ability.CastTarget(item, enemy)

                    local distance = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
                    local delay = distance / 1275     -- the projectile of ethereal blade travels at a speed of 1275.
                    local offset = 0.1

                    KS_target = enemy
                    KS_time = GameRules.GetGameTime() + delay - cast_point + offset
                    return
                end
            end
        end
    end
end

function Lion.KillStealHelper()
    if not KS_target or not KS_time then return end
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "lion_finger_of_death")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    if GameRules.GetGameTime() - 0.05 <= KS_time and KS_time <= GameRules.GetGameTime() + 0.05 
    and Utility.CanCastSpellOn(KS_target) and not Utility.IsLinkensProtected(KS_target)
    and not Utility.IsDiskProtected(KS_target)
    and NPC.IsEntityInRange(myHero, KS_target, range) then
        Ability.CastTarget(spell, KS_target)
        KS_target = nil
    end
end

function Lion.AutoHex()
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end
    -- if NPC.GetCurrentLevel(myHero) < 6 then return end

    local spell = NPC.GetAbility(myHero, "lion_voodoo")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    local indices = Utility.GetHeroIndicesOrderedByDistance()
    for k, v in ipairs(indices) do
        local enemy = Heroes.Get(v)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and (Utility.GetFixTimeLeft(enemy) <= 0.3 or not Utility.IsDisabled(enemy))
        and not Utility.IsLinkensProtected(enemy) and not Utility.IsLotusProtected(enemy) then

            if NPC.GetCurrentLevel(myHero) < 30 then
                Ability.CastTarget(spell, enemy)
            else
                Ability.CastPosition(spell, Entity.GetAbsOrigin(enemy))
            end
            return
        end
    end
end

function Lion.AutoSpike()
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "lion_impale")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    local range = Ability.GetCastRange(spell)
    -- reference: https://dota2.gamepedia.com/Lion
    -- real range = travel distance + radius
    local real_range = range + 325 + 125

    local damage = 20 + 60 * Ability.GetLevel(spell)
    local speed = 1600

    local directions = {}

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, real_range)
        and not Utility.IsLinkensProtected(enemy) and not Utility.IsLotusProtected(enemy) then

            -- use maximum cast range of spike (consider travel distance and radius)
            local cast_position
            if NPC.IsEntityInRange(myHero, enemy, range) then
                cast_position = Entity.GetAbsOrigin(enemy)
            else
                local direction = (Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(myHero)):Normalized()
                cast_position = Entity.GetAbsOrigin(myHero) + direction:Scaled(range)
            end

            -- spike the enemy who is channelling a spell or TPing
            if Utility.IsChannellingAbility(enemy) then
                Ability.CastPosition(spell, cast_position)
                return
            end

            -- spike the enemy who is very close
            if NPC.IsEntityInRange(myHero, enemy, 300) and not Utility.IsDisabled(enemy) then
                Ability.CastPosition(spell, cast_position)
                return
            end

            -- spike the enemy who is hexed/stunned/rooted/taunted with proper timing
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
            local delay = 0.3 + dis/speed
            local offset = 0.5

            if (Utility.GetHexTimeLeft(enemy) - offset <= delay and Utility.GetHexTimeLeft(enemy) > delay)
            or (Utility.GetFixTimeLeft(enemy) - offset <= delay and Utility.GetFixTimeLeft(enemy) > delay) then
                Ability.CastPosition(spell, cast_position)
                return
            end

            -- -- spike the enemy who is in low HP (for kill steal)
            -- local true_damage = Utility.GetRealDamage(myHero, enemy, damage)
            -- if true_damage >= Entity.GetHealth(enemy)+NPC.GetHealthRegen(enemy)*delay then
            --     Ability.CastPosition(spell, cast_position)
            --     return
            -- end

            -- spike if two or more enemies are on the same line
            local dir = (Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(myHero)):Normalized()
            for k, v in pairs(directions) do
                if k ~= NPC.GetUnitName(enemy) and (v - dir):Length() < 0.01 then
                    Ability.CastPosition(spell, cast_position)
                    return
                end
            end
            directions[NPC.GetUnitName(enemy)] = dir
        end
    end
end

function Lion.AutoManaDrain()
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "lion_mana_drain")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    local indices = Utility.GetHeroIndicesOrderedByDistance()
    for k, v in ipairs(indices) do
        local enemy = Heroes.Get(v)
        if enemy and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            if Utility.IsLinkensProtected(enemy) then
                Ability.CastTarget(spell, enemy)
                return
            end

            if NPC.IsIllusion(enemy)
                and NPC.GetUnitName(enemy) ~= "npc_dota_hero_arc_warden"
                and NPC.GetUnitName(enemy) ~= "npc_dota_hero_chaos_knight"
                and NPC.GetUnitName(enemy) ~= "npc_dota_hero_vengefulspirit" then

                Ability.CastTarget(spell, enemy)
                return
            end
        end
    end
end

function Lion.IsSuitableToCastSpell(myHero)
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    -- disable this check for mana_drain
    -- if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

return Lion
