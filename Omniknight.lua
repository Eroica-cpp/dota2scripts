local Utility = require("Utility")

local Omniknight = {}

local optionKillSteal = Menu.AddOption({"Hero Specific", "Omniknight"}, "Kill Steal", "Cast purification on allies to KS")
local optionAutoSave = Menu.AddOption({"Hero Specific", "Omniknight"}, "Auto Save", "Auto save allies with purification or repel")

function Omniknight.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        Omniknight.KillSteal()
    end

    if Menu.IsEnabled(optionAutoSave) then
        Omniknight.AutoSave()
    end
end

function Omniknight.AutoSave()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local purification = NPC.GetAbility(myHero, "omniknight_purification")
    local repel = NPC.GetAbility(myHero, "omniknight_repel")

    for i = 1, Heroes.Count() do
        local ally = Heroes.Get(i)
        if ally and not NPC.IsIllusion(ally) and Entity.IsSameTeam(myHero, ally) and Utility.CanCastSpellOn(ally) then

            if Utility.NeedToBeSaved(ally) and NPC.IsEntityInRange(myHero, ally, Ability.GetCastRange(repel))
            and repel and Ability.IsCastable(repel, NPC.GetMana(myHero)) then
                Ability.CastTarget(repel, ally)
            end

            if Entity.GetHealth(ally) <= 0.3 * Entity.GetMaxHealth(ally) and NPC.IsEntityInRange(myHero, ally, Ability.GetCastRange(purification))
            and purification and Ability.IsCastable(purification, NPC.GetMana(myHero)) then
                Ability.CastTarget(purification, ally)
            end
        end
    end
end

function Omniknight.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero or not Utility.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "omniknight_purification")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end

    local radius = 260
    local range = Ability.GetCastRange(spell)

    local damage = 20 + 70 * Ability.GetLevel(spell)
    if NPC.GetCurrentLevel(myHero) >= 25 then damage = damage + 200 end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and damage >= Entity.GetHealth(enemy) then

            local units = NPC.GetUnitsInRadius(enemy, radius, Enum.TeamType.TEAM_ENEMY)
            for j, ally in ipairs(units) do
                if ally and NPC.IsEntityInRange(myHero, ally, range) and Utility.CanCastSpellOn(ally) then
                    Ability.CastTarget(spell, ally)
                    return
                end
            end
        end
    end
end

return Omniknight
