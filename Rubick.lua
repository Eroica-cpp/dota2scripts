local Utility = require("Utility")

local Rubick = {}

local optionAutoTelekinesis = Menu.AddOption({"Hero Specific", "Rubick"}, "Auto Telekinesis", "Auto cast Telekinesis on any enemy in range once rubick has level 6")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Rubick"}, "Kill Steal", "Cast spell on enemy to KS")
local optionAutoSpellSteal = Menu.AddOption({"Hero Specific", "Rubick"}, "Auto Spell Steal", "Auto steal important spells")

function Rubick.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        Rubick.KillSteal()
    end

    if Menu.IsEnabled(optionAutoTelekinesis) then
        Rubick.AutoTelekinesis()
    end

    if Menu.IsEnabled(optionAutoSpellSteal) then
        Rubick.AutoSpellSteal()
    end
end

function Rubick.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "rubick_fade_bolt")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    local range = Ability.GetCastRange(spell)
    local damage = 80 * Ability.GetLevel(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            if true_damage >= Entity.GetHealth(enemy) then
                Ability.CastTarget(spell, enemy)
                return
            end
        end
    end
end

function Rubick.AutoTelekinesis()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end
    if NPC.GetCurrentLevel(myHero) < 6 then return end

    local spell = NPC.GetAbility(myHero, "rubick_telekinesis")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

function Rubick.AutoSpellSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local steal = NPC.GetAbility(myHero, "rubick_spell_steal")
    if not steal or not Ability.IsCastable(steal, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(steal)

    -- don't steal if currently has stolen spells available
    local slot1 = NPC.GetAbilityByIndex(myHero, 3)
    local slot2 = NPC.GetAbilityByIndex(myHero, 4)
    if (slot1 and Ability.IsCastable(slot1, NPC.GetMana(myHero))) or (slot2 and Ability.IsCastable(slot2, NPC.GetMana(myHero))) then return end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            local spell = Rubick.GetLastSpell(enemy)
            if spell and Ability.GetName(spell) == "sven_storm_bolt" then
                Ability.CastTarget(steal, enemy)
                return
            end
        end
    end
end

function Rubick.GetLastSpell(enemy)
    if not enemy then return end

    local min = 999999
    local res
    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(enemy, i)
        if ability and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
            local lastUsed = Ability.SecondsSinceLastUse(ability)

            -- Ability.SecondsSinceLastUse returns -1 if it isn't on cooldown.
            if lastUsed == -1 then lastUsed = 999999 end

            if lastUsed < min then
                res = ability
                min = lastUsed
            end
        end
    end

    return res
end

return Rubick
