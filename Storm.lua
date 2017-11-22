local Utility = require("Utility")

local Storm = {}

local optionAutoVortex = Menu.AddOption({"Hero Specific", "Storm Spirit"}, "Auto Vortex", "Auto vortex any enemy in range")

function Storm.OnUpdate()
    if Menu.IsEnabled(optionAutoVortex) then
        Storm.AutoVortex()
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
