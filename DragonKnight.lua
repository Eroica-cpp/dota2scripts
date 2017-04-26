local Utility = require("Utility")

local DragonKnight = {}

local optionKillSteal = Menu.AddOption({"Hero Specific", "Dragon Knight"}, "Kill Steal", "Cast breathe fire on enemy to KS")
local optionAutoStun = Menu.AddOption({"Hero Specific", "Dragon Knight"}, "Auto Stun", "Auto stun enemy in range")
local optionAwareness = Menu.AddOption({"Hero Specific", "Dragon Knight"}, "Awareness", "Show how many hits left to kill enemy")
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function DragonKnight.OnUpdate()
    if Menu.IsEnabled(optionKillSteal) then
        DragonKnight.KillSteal()
    end

    if Menu.IsEnabled(optionAutoStun) then
        DragonKnight.AutoStun()
    end
end

function DragonKnight.OnDraw()
    if not Menu.IsEnabled(optionAwareness) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_dragon_knight" then return end

    local fire_damage = 0
    local fire = NPC.GetAbility(myHero, "dragon_knight_breathe_fire")
    if fire and Ability.IsCastable(fire, NPC.GetMana(myHero)) then
        fire_damage =  20 + 70 * Ability.GetLevel(fire)
    end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
            
            local enemyHp = Entity.GetHealth(enemy)
            local physical_damage = NPC.GetDamageMultiplierVersus(myHero, enemy) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy) 
            local magical_damage = fire_damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            local enemyHpLeft = enemyHp - magical_damage
            local hitsLeft = math.ceil(enemyHpLeft / (physical_damage + 1))
            
            -- draw
            local pos = Entity.GetAbsOrigin(enemy)
            local x, y, visible = Renderer.WorldToScreen(pos)

              -- red : can kill; green : cant kill
            if enemyHpLeft <= 0 then
                Renderer.SetDrawColor(255, 0, 0, 255)
                Renderer.DrawTextCentered(font, x, y, "Kill", 1)
            else
                Renderer.SetDrawColor(0, 255, 0, 255)
                Renderer.DrawTextCentered(font, x, y, hitsLeft, 1)
            end
        end
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

function DragonKnight.AutoStun()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end

    local stun = NPC.GetAbility(myHero, "dragon_knight_dragon_tail")
    if not stun or not Ability.IsCastable(stun, NPC.GetMana(myHero)) then return end

    local range = 150
    if NPC.HasModifier(myHero, "modifier_dragon_knight_dragon_form") then range = 400 end

    local enemyHeroes = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    if not enemyHeroes or #enemyHeroes <= 0 then return end

    for i, enemy in ipairs(enemyHeroes) do
        if not NPC.IsIllusion(enemy) and Utility.CanCastSpellOn(enemy) and not Utility.IsLotusProtected(enemy) and not Utility.IsDisabled(enemy) then
            Ability.CastTarget(stun, enemy)
            return
        end
    end
end

return DragonKnight