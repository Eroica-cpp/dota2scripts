local Utility = require("Utility")


local Abaddon = {}

local optionAutoSave = Menu.AddOption({"Hero Specific", "Abaddon"}, "Auto Save", "Auto cast 'Aphotic Shield' to save needed ally")
local optionKillSteal = Menu.AddOption({"Hero Specific", "Abaddon"}, "Kill Steal", "Auto cast 'Mist Coil' to KS")
local optionAwareness = Menu.AddOption({"Hero Specific", "Abaddon"}, "Awareness", "Show how many hits left to kill enemy")
local font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function Abaddon.OnUpdate()
    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Utility.IsSuitableToCastSpell(myHero) then return end
    
    if Menu.IsEnabled(optionAutoSave) then
        Abaddon.AutoSave(myHero)
    end

    if Menu.IsEnabled(optionKillSteal) then
        Abaddon.KillSteal(myHero)
    end
end

function Abaddon.OnDraw()
	if not Menu.IsEnabled(optionAwareness) then return end

    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_abaddon" then return end

    local coil_damage = 0
    local coil = NPC.GetAbility(myHero, "abaddon_death_coil")
    if coil and Ability.IsCastable(coil, NPC.GetMana(myHero)) then
        coil_damage = 50 + 50 * Ability.GetLevel(coil)
    end

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and Entity.IsAlive(enemy) then
            
            local enemyHp = Entity.GetHealth(enemy)
            local physical_damage = NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy) 
            local magical_damage = coil_damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
            local enemyHpLeft = enemyHp - magical_damage
            local hitsLeft = math.ceil(enemyHpLeft / math.max(physical_damage, 1))
            
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

function Abaddon.KillSteal(myHero)
    local coil = NPC.GetAbility(myHero, "abaddon_death_coil")
    if not coil or not Ability.IsCastable(coil, NPC.GetMana(myHero)) then return end
    local damage = 50 + 50 * Ability.GetLevel(coil)

    local range = 800
    local enemies = NPC.GetHeroesInRadius(myHero, range, Enum.TeamType.TEAM_ENEMY)
    if not enemies or #enemies <= 0 then return end

    for i, enemy in ipairs(enemies) do
    	local true_damage = damage * NPC.GetMagicalArmorDamageMultiplier(enemy)
	    if Entity.GetHealth(enemy) <= true_damage and Utility.CanCastSpellOn(enemy) then
	        Ability.CastTarget(coil, enemy)
	        return
	    end
    end
end

return Abaddon