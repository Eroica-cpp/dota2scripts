local Utility = require("Utility")

local Rubick = {}

local optionAutoTelekinesis = Menu.AddOption({"Hero Specific", "Rubick"}, "Auto Telekinesis", "Auto cast Telekinesis on any enemy in range once rubick has level 6")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Rubick"}, "Kill Steal", "Cast spell on enemy to KS")

function Rubick.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        Rubick.KillSteal()
    end

    if Menu.IsEnabled(optionAutoTelekinesis) then
        Rubick.AutoTelekinesis()
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

return Rubick
