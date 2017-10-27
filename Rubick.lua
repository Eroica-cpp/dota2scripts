local Utility = require("Utility")

local Rubick = {}

local optionKillSteal = Menu.AddOption({"Hero Specific", "Rubick"}, "Kill Steal", "Cast spell on enemy to KS")

function Rubick.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    if Menu.IsEnabled(optionKillSteal) then
        Rubick.KillSteal()
    end
end

function Rubick.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero then return end

    local bolt = NPC.GetAbility(myHero, "rubick_fade_bolt")
    if not bolt or not Ability.IsCastable(bolt, NPC.GetMana(myHero)) then return end

    local range = 800
    local damage = 80 * Ability.GetLevel(bolt)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            if true_damage >= Entity.GetHealth(enemy) then
                Ability.CastTarget(bolt, enemy)
                return
            end
        end
    end
end

return Rubick
