local Utility = require("Utility")


local Abaddon = {}

local optionAutoSave = Menu.AddOption({"Hero Specific", "Abaddon"}, "Auto Save", "Auto cast 'Aphotic Shield' to save needed ally")

function Abaddon.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end
    
    if Menu.IsEnabled(optionAutoSave) then
        Abaddon.AutoSave(myHero)
    end
end

function Abaddon.AutoSave(myHero)
    local shield = NPC.GetAbility(myHero, "abaddon_aphotic_shield")
    if not shield or not Ability.IsCastable(shield, NPC.GetMana(myHero)) then return end

    if Utility.NeedToBeSaved(myHero) and Utility.CanCastSpellOn(myHero) then
        Ability.CastTarget(shield, myHero)
        return
    end

    local range = 500
    local allies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_FRIEND)
    for i, ally in ipairs(allies) do
	    if Utility.NeedToBeSaved(ally) and Utility.CanCastSpellOn(ally) then
	        Ability.CastTarget(shield, ally)
	        return
	    end
    end
end

return Abaddon