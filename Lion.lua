local Utility = require("Utility")

local Lion = {}

local optionAutoHex = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Hex", "Auto hex any enemy in range once lion has level 6")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Lion"}, "Auto KS (upgraded version)", "Auto kill steal using finger of death and/or ethereal blade.")
local optionKillStealCounter = Menu.AddOption({"Hero Specific", "Lion"}, "Show KS Counter", "Show how many hits remains to kill steal.")
local optionAutoSpike = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Spike", "Auto spike if enemy is (1) in low HP (kill steal); (2) TPing; (3) channelling; or (4) being stunned or hexed with proper timing")
local optionAutoManaDrain = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Mana Drain", "Auto mana drain to break (1) linken (or AM's shell); (2) illusion")

local KS_target
local KS_time

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

-- show how many hits left to KS
function Lion.OnDraw()
    if not Menu.IsEnabled(optionKillStealCounter) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_lion" then return end
    if NPC.GetCurrentLevel(myHero) < 6 then return end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and spell_damage_table[NPC.GetUnitName(enemy)] 
        	and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then

            local oneHitDamage = NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy)
            local hitsLeft = math.ceil((Entity.GetHealth(enemy) - spell_damage_table[NPC.GetUnitName(enemy)]) / oneHitDamage)

            -- draw
            local pos = Entity.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)
            local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

            -- red : can kill; green : cant kill
            if hitsLeft <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
                Renderer.DrawTextCentered(font, x, y, hitsLeft, 1)
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
    if NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
        base_damage = 725 + 150 * (Ability.GetLevel(spell) - 1)
    else
        base_damage = 600 + 125 * (Ability.GetLevel(spell) - 1)
    end

    local additional_damage = 0
    local mod = NPC.GetModifier(myHero, "modifier_lion_finger_of_death_kill_counter")
    if mod then
        kill_counter = Modifier.GetStackCount(mod)
        if NPC.GetCurrentLevel(myHero) >= 20 then
            additional_damage = 60 * kill_counter
        else
            additional_damage = 40 * kill_counter
        end
    end

    local total_damage = base_damage + additional_damage

    local ethereal_base_damage = 0
    local ethereal_amplified_damage = 0
    local item = NPC.GetItem(myHero, "item_ethereal_blade", true)
    if item and Ability.IsCastable(item, NPC.GetMana(myHero)) then
        ethereal_base_damage = 125 + 1.5 * Hero.GetIntellectTotal(myHero)
        ethereal_amplified_damage = 0.4 * total_damage
    end 

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) then

            local true_damage = Utility.GetRealDamage(myHero, enemy, total_damage)
            spell_damage_table[NPC.GetUnitName(enemy)] = true_damage

            if true_damage >= Entity.GetHealth(enemy) and Utility.IsSafeToCast(myHero, enemy, true_damage)
                and Utility.CanCastSpellOn(enemy) and not Utility.IsLinkensProtected(enemy)
                and NPC.IsEntityInRange(myHero, enemy, range) and Ability.IsCastable(spell, NPC.GetMana(myHero)) then

                Ability.CastTarget(spell, enemy)
                return
            end

            if item and Ability.IsCastable(item, NPC.GetMana(myHero) - Ability.GetManaCost(spell)) then

                true_damage = Utility.GetRealDamage(myHero, enemy, total_damage + ethereal_base_damage + ethereal_amplified_damage)
                spell_damage_table[NPC.GetUnitName(enemy)] = true_damage

                if true_damage >= Entity.GetHealth(enemy) and Utility.IsSafeToCast(myHero, enemy, true_damage)
                    and Utility.CanCastSpellOn(enemy) and not Utility.IsLinkensProtected(enemy)
                    and NPC.IsEntityInRange(myHero, enemy, range) and Ability.IsCastable(spell, NPC.GetMana(myHero)) then

                    Ability.CastTarget(item, enemy)

                    local distance = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
                    local delay = distance / 1275     -- the projectile of ethereal blade travels at a speed of 1275.
                    local cast_point = 0.3            -- the cast point of finger of death
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
    and Utility.CanCastSpellOn(KS_target) and not Utility.IsLinkensProtected(KS_target) and NPC.IsEntityInRange(myHero, KS_target, range) then
        Ability.CastTarget(spell, KS_target)
    end
end

function Lion.AutoHex()
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end
    -- if NPC.GetCurrentLevel(myHero) < 6 then return end

    local spell = NPC.GetAbility(myHero, "lion_voodoo")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsDisabled(enemy) and not Utility.IsLinkensProtected(enemy)
        and not Utility.IsLotusProtected(enemy) then

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
    local damage = 20 + 60 * Ability.GetLevel(spell)
    local speed = 1600

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            -- spike the enemy who is channelling a spell or TPing
            if Utility.IsChannellingAbility(enemy) then
                Ability.CastPosition(spell, Entity.GetAbsOrigin(enemy))
                return
            end

            -- spike the enemy who is being stunned or hexed with proper timing
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
            local delay = 0.3 + dis/speed

            if (Utility.GetHexTimeLeft(enemy) - 0.1 < delay and delay < Utility.GetHexTimeLeft(enemy) + 0.1)
            or (Utility.GetStunTimeLeft(enemy) - 0.1 < delay and delay < Utility.GetStunTimeLeft(enemy) + 0.1) then
                Ability.CastPosition(spell, Utility.GetPredictedPosition(enemy, delay))
                return
            end

            -- spike the enemy who is in low HP (for kill steal)
            local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            if true_damage >= Entity.GetHealth(enemy) then
                Ability.CastPosition(spell, Utility.GetPredictedPosition(enemy, delay))
                return
            end
        end
    end
end

function Lion.AutoManaDrain()
    local myHero = Heroes.GetLocal()
    if not myHero or not Lion.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "lion_mana_drain")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            if Utility.IsLinkensProtected(enemy) or NPC.IsIllusion(enemy) then
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
