local Utility = require("Utility")

local BountyHunter = {}

local optionAutoTrack = Menu.AddOption({"Hero Specific", "Bounty Hunter"}, "Auto Track", "Auto cast track on enemies in range")

function BountyHunter.OnUpdate()
    if Menu.IsEnabled(optionAutoTrack) then
        BountyHunter.AutoTrack()
    end
end

function BountyHunter.AutoTrack()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "bounty_hunter_track")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range)
        and BountyHunter.GetTrackTimeLeft(enemy) <= Ability.GetCooldownLength(spell) then

            Ability.CastTarget(spell, enemy)
            return
        end
    end
end

function BountyHunter.GetTrackTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_bounty_hunter_track")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

return BountyHunter
