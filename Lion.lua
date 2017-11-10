local Utility = require("Utility")

local Lion = {}

local optionAutoHex = Menu.AddOption({"Hero Specific", "Lion"}, "Auto Hex", "Auto hex any enemy in range once lion has level 6")

function Lion.OnUpdate()
    if Menu.IsEnabled(optionAutoHex) then
        Lion.AutoHex()
    end
end

function Lion.AutoHex()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end
    if NPC.GetCurrentLevel(myHero) < 6 then return end

    local spell = NPC.GetAbility(myHero, "lion_voodoo")
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

return Lion
