local Utility = require("Utility")

local DragonKnight = {}

local optionKillSteal = Menu.AddOption({"Hero Specific", "Dragon Knight"}, "Kill Steal", "Cast breathe fire on enemy to KS")

function DragonKnight.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        DragonKnight.KillSteal()
    end
end

function DragonKnight.KillSteal()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end

    local fire = NPC.GetAbility(myHero, "dragon_knight_breathe_fire")
    if not fire or not Ability.IsCastable(fire, NPC.GetMana(myHero)) then return end

    local damage =  20 + 70 * Ability.GetLevel(fire)

    local range = 900
    local enemyHeroes = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    if not enemyHeroes or #enemyHeroes <= 0 then return end

    for i, enemy in ipairs(enemyHeroes) do
        local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
        if not NPC.IsIllusion(enemy) and Utility.CanCastSpellOn(enemy) and Entity.GetHealth(enemy) <= true_damage then
            local dir = Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(myHero)
            local pos = Entity.GetAbsOrigin(myHero) + dir:Normalized():Scaled(450)
            Ability.CastPosition(fire, pos)
            return
        end
    end
end

return DragonKnight