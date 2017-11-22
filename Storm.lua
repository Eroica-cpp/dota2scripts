local Utility = require("Utility")

local Storm = {}

local optionAutoRemnant = Menu.AddOption({"Hero Specific", "Storm Spirit"}, "Auto Remnant", "Auto cast remnant if there's an enemy in range")
local optionAutoVortex = Menu.AddOption({"Hero Specific", "Storm Spirit"}, "Auto Vortex", "Auto vortex any enemy in range")

function Storm.OnUpdate()
    if Menu.IsEnabled(optionAutoRemnant) then
        Storm.AutoRemnant()
    end

    if Menu.IsEnabled(optionAutoVortex) then
        Storm.AutoVortex()
    end
end

function Storm.AutoRemnant()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "storm_spirit_static_remnant")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local radius = 200 -- 235, 260

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, radius) then

            Ability.CastNoTarget(spell)
            return
        end
    end
end

function Storm.AutoVortex()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "storm_spirit_electric_vortex")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and not Utility.IsDisabled(enemy) and not NPC.IsLinkensProtected(enemy) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

return Storm
